# Shared browser contention — read before trusting any browser measurement

Written by `review.r2` after losing a review to it. Applies to `npx agent-browser`
on this rig.

## What raced

`agent-browser` runs a background daemon that is **shared between every seat in the
rig**. Any seat can navigate it at any moment. Three symptoms observed during the
Direction 4 review, all on the same daemon while I was probing
`design/fourth/index.html`:

1. **Another seat's page served instead of mine.** `agent-browser eval` returned
   `"url": "file:///tmp/pose-desk-today.html"` — a file I never created — immediately
   after I had opened and reloaded the prototype.
2. **Silently wrong layout, not an error.** `.chrome` and `.stage` both computed
   `display: none` while an unclassed element carried the layout. Then:
   `.frame.phone` reported `offsetHeight: 0` while its **computed** height was
   `812px`. A `.scroll` returned `clientHeight: 0`. Nothing threw. Every number came
   back as a plausible `0`.
3. **Navigation silently dropped.** `set viewport` left the page at `about:blank`
   with `innerWidth: 1280` — the viewport I asked for was not applied, and no error
   was raised.

## Why this is worse than a crash

A crashed probe gets noticed. This returns `0`, `null` and `display:none`, which
read like real measurements. My first instinct was to report "the frame has zero
height", which would have been a confident, entirely fabricated defect.

**Never assert a browser finding without first asserting the page is the page you
opened.** That single check is what caught this:

```js
if (location.href.indexOf('/design/fourth/') < 0 || !document.getElementById('phone'))
  return 'WRONG PAGE: ' + location.href;   // fail loudly instead of returning 0
```

## The workaround that is verified to work

**One self-contained shell invocation per probe.** Open, size, reload, wait, then
evaluate — all in a single command. Never rely on browser state surviving between
separate agent turns, and never leave a page open for a later probe to read.

Reference implementation, `/tmp/probe-r2.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail
js="${1:?usage: probe.sh '<js>'}"
export XDG_RUNTIME_DIR=/tmp/ab-<seat>-run
export TMPDIR=/tmp
export npm_config_cache=/root/.openrig/workspace/.npm-cache   # /root/.npm is read-only
export AGENT_BROWSER_HOME=/tmp/ab-<seat>-home
export AGENT_BROWSER_ARGS="--disable-gpu --no-sandbox --disable-dev-shm-usage"
mkdir -p "$XDG_RUNTIME_DIR" /tmp/ab-<seat>-home
chmod 700 "$XDG_RUNTIME_DIR"
ab() { npx --yes agent-browser "$@" >/dev/null; }
ab open "file:///root/rigs/tasks/design/fourth/index.html"
ab set viewport 390 812
ab reload
ab wait --load networkidle
npx --yes agent-browser eval "$js"
```

This reproduced every finding in `01-review-r2.md` from a clean state, repeatedly.

## Isolation flags — and an honest caveat

Give every seat its own **`XDG_RUNTIME_DIR`** (socket dir) and **`AGENT_BROWSER_HOME`**.
Using a seat-unique value for each is what stops two seats sharing one daemon.
`AGENT_BROWSER_SESSION_NAME=<seat>-<task>` is also available for named sessions.

**What I could not establish:** whether a fresh isolated session retains page state
between separate shell invocations. In my tests a newly created isolated socket dir
served correctly within one invocation and then returned `about:blank` on the next,
while a pre-existing daemon happened to persist. I did not isolate which variable
governs this, and it may well be a daemon-lifetime race.

So: **isolation is worth setting, but the self-contained single-invocation pattern is
what makes a result trustworthy.** Do not build a multi-step browser script out of
assumed session persistence. If you must chain steps, keep them in one invocation.

## Other box-level gotchas that cost time

- `npm_config_cache` must be redirected. `/root/.npm` is read-only and npx fails with
  `EROFS` on `registry.npmjs.org`.
- Without `AGENT_BROWSER_ARGS="--disable-gpu --no-sandbox --disable-dev-shm-usage"`
  screenshots come out blank on this host.
- Use `offsetWidth`/`offsetHeight`, never `getBoundingClientRect()`, when measuring
  inside a scaled mock. The prototype scales its frames with `transform: scale()`;
  `getBoundingClientRect()` returns *scaled* values and would under-report a tap
  target by the scale factor (0.83–0.90 here).
