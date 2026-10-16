# Independent review — Direction 4, week-survival lens

Reviewer: `review.r2` (Codex). Target: `design/fourth/index.html` as of `3eba88a`.
Lens: **will this survive a week of daily use holding only a phone?** Day 3, 7, 30.
Method: read source, then drove the prototype in isolated headless Chrome at 390×812.
No file in the target was modified.

All numbers below are measured values, not estimates. Reproduce with
`/tmp/probe-r2.sh '<js>'` (self-contained; the shared agent-browser daemon is
raced by other seats and must not be trusted).

> **Correction, recorded after the fact.** This review was written against the
> *working tree*, which I initially labelled `817f42a`. That label was wrong: the
> working tree already contained the pin-dedup fix that was only committed later as
> `3eba88a`. Every line citation and every measurement below was re-verified against
> `3eba88a` and is correct there. The reviewed content is `3eba88a`, not `817f42a`.

---

## HIGH 1 — Filing is a one-way door, and it is the front door

`file()` is the only write to `it.when` outside capture, and it only ever writes a
truthy value:

- `index.html:459` — `function file(id, when){ ...; it.when = when; render(); }`
- `index.html:537-540` — the only choices offered are `today / tomorrow / week / someday`
- `data-when=""` exists only on the capture sheet (`:586`), i.e. **only at capture time**
- `grep -niE 'undo|snackbar|revert'` → **no matches. There is no undo anywhere.**

Once a task is filed it can never return to the inbox. Measured: an 18-item inbox is
17 triage cards at 154px each, 4 per 640px viewport = **4.1 screens, 68 taps, no bulk
action, no undo**.

Consequence: every day's first screen is an irreversible chores list. A task filed
to Today on a phone, by accident, is gone from the inbox permanently and cannot be
recovered. This is the mechanism that ends week-two use — not a missing feature.

## HIGH 2 — "Do it today" is a ratchet that pushes old work into today

The pin carries exactly one affordance, and it moves the oldest item into Today
unconditionally (`index.html:529`). Measured, re-querying each step so the pin is
re-read after every re-render:

```
23 days :: Find the passport photo I took in March
16 days :: Renew the bike insurance
 3 days :: Cancel the second monitor order, wrong size
(none)
Today tab: 8 → 11
```

**Three taps filed three arbitrary old tasks into Today** and then drained the pin
empty. The pin immediately re-promotes the next-oldest, so tapping it is a treadmill:
you cannot close out the old thing, you can only convert old things into today's list.
There is no alternative action on the pin (no "not now", no "delete", no "ignore").

This is the direct answer to the assigned question: yes, it actively pushes the wrong
old task — the oldest is not the most relevant, and selection is purely `max(days)`
(`index.html:345-348`).

## HIGH 3 — The prototype cannot demonstrate the only thing it is being judged on

Both grafts are time-dependent. Neither moves.

- `grep -nE 'new Date|Date.now'` → **no matches anywhere in the file**
- `index.html:302` — `const DBAR_A = 6, DBAR_B = 23, NOW = 9.75;` — the "now" line is
  frozen at 09:45 forever (`NOW` is read at `:511` and never recomputed)
- `index.html:414` — `addItem` sets `days: 0`; **nothing ever increments `days`**
- `index.html:346` — the carried pool requires `i.days > 0`

Measured: three tasks captured through the real UI all hold `days: 0` and **none enter
the carried pool**:

```
newlyCaptured: [{"t":"Renew passport","days":0},
                {"t":"Book the vet","days":0},
                {"t":"Call the bank","days":0}]
carriedPool:   ["Find the passport photo…","Cancel the second monitor…",
                "Renew the bike insurance"]   // seed data only
```

Consequence, stated precisely: `days: 0` is a placeholder and an implementer would
wire it to a capture timestamp — that part is a prototype wart, not a shipped defect.
But the owner is being asked to judge *"does the carried-longest pin still motivate on
day 30?"* on an artifact where **no captured task can ever become carried-longest and
no clock ever advances.** The feature cannot be evaluated in the form shown. Note this
is independent of HIGH 2: perfect timestamps would still yield the ratchet.

## MEDIUM 4 — The most-repeated action has a 26px target

Measured: all 8 triage buttons are **75 × 26px** (`offsetWidth/offsetHeight`, which
ignores the demo's transform scale). iOS HIG minimum is 44pt, Material 48dp — this is
41% below the iOS minimum. Capture's Save button is 280 × **38px**, also under minimum,
on the app's single most important action.

Only filing happens on the small targets, and it happens 4× per card, 68× per
18-item inbox. With no undo (HIGH 1), this converts routine thumb imprecision into
permanent data loss.

## MEDIUM 5 — Nothing in the file handles the phone keyboard or safe areas

`grep -niE 'dvh|svh|visualViewport|interactive-widget|env\(safe-area'` → **no matches**.
The only viewport unit in the file is `min-height:100vh` (`:16`).

The capture sheet is bottom-anchored (`:174`) and its Save button measures **62–99px
above the bottom of the app** — squarely inside the region a phone keyboard occupies
(iOS ≈336pt, Android ≈280–300dp). The primary action of the primary flow is specified
into the keyboard's path, with no strategy specified to avoid it.

Stated honestly: the prototype renders inside a fixed 812px mock, so it *cannot*
demonstrate keyboard behaviour either way — I have verified the geometry and the
absence of any handling, and am inferring the collision from standard device metrics,
not observing it. It is a question the artifact leaves unanswerable.

## LOW 6 — Two identical capture buttons, one of them disguised as a tab

Measured: `[data-act="open"]` matches a 74×63 tabbar button labelled "Capture" *and* a
58×58 FAB labelled "New task". Same action, two places, same screen. The tabbar one
sits between "Today" and "Later" styled identically to the four real tabs, so the tab
bar reads as five destinations where four are navigation and one is an action.

## LOW 7 — FAB occludes the last inbox card

Measured at scroll-bottom: FAB intersects the final card by 168px². It occludes the
card's right padding, **not** its text (text ends 47px from the card edge, FAB begins
60px from it) and not the complete control. Cosmetic, not blocking.

---

## Answers to the assigned questions

**1. Capture — taps, and does it degrade?**
**Two taps + typing** (`fab` → sheet auto-focuses textarea via `:740` → `save`). Capture
does not degrade as the inbox grows; it is O(1) and nothing is discarded — the spine is
genuinely good and I verified it. The degradation is not in capture, it is in what the
app makes you do *afterwards*: 4.1 screens and 68 irreversible taps per 18-item inbox.

**2. Does the pin stay motivating?**
It stops being informational within one session. The measurement above shows it drains
the inbox into Today. There is no action on the pin other than "Do it today", no way to
dismiss or snooze it, and the pool it draws from (`days > 0`) is unreachable for real
captures (HIGH 3). It becomes a button that promotes old work, which is the one thing a
daily-use app must not do.

**3. What does it look like to someone for whom time is inert?**
An empty ruler. Measured with all times null: the bar renders **0 marks against 18
hourlines** — a grey box with a red 09:45 line — headed **"3 of 14 closed · 21% of the
day"** and **"0 placed · 11 with no time"**, and every one of the 11 cards carries a
dead "no time yet" chip. The "21% of the day" is a progress claim about a day shape
that does not exist. The feature is opt-out but its empty state is opt-*in*.

**4. Inbox full of undated items — still useful?**
Triage becomes the product. 18 items → 4.1 screens, 68 taps, no bulk action, no undo,
and the inbox is the app's front door. Every day opens on a chores list that cannot be
short-circuited.

**5. The single first change**
**Make filing reversible.** One change in one place (`file()` at `:459` plus the toast):
every file action gets an undo / "back to inbox", and the inbox re-opens as a valid
destination after the fact.

Rationale: it is the only change that makes the *existing* design survivable rather than
redesigned. It makes the 26px targets in MEDIUM 4 harmless, it makes impulsive pin taps
in HIGH 2 cheap, and it lets the owner triage sloppily on a phone — which is the only
mode triage survives at 68 taps. Without it, fixing tap targets only lowers the price of
an irreversible mistake.

---

## Verdict

**No — not as-is.**

The spine is right and worth building: capture in two taps, no decisions at capture,
nothing discarded, filing deferred. I verified that part and it holds.

What is not shippable is the path the owner walks *after* capture. The inbox is the
front door; filing is irreversible, un-bulkable, on sub-minimum targets, and there is
no path back. On a phone that combination does not survive day seven — it does not
need a missing feature to fail, only the mechanics already in the file.

Ship the Inbox spine. Make filing reversible. Make the pin honest (real timestamps, and
an action that is not "Do it today") or cut it. Treat the day bar as unproven until it
has been seen with a clock.
