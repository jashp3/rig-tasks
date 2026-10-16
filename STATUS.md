
# Status

Single source of truth for any agent picking this up cold. Read this first,
then `SPEC.md`, then `missions/daily-task-app/SPEC.md`.

## Phase

**Design exploration. Nothing is implemented.** Four directions built as
working prototypes; the owner is choosing between them.

## Live

- Prototypes: **https://jashp3.github.io/rig-tasks/**
- Repo: `git@github.com:jashp3/rig-tasks.git` (private, pushed from here)
- Push with `git push origin main`. Pages redeploys automatically.

## The four directions

| | Structure | Spine |
|---|---|---|
| `design/inbox/` | capture-first triage | recommended baseline |
| `design/now/` | clock / day timeline | |
| `design/threads/` | no lists, no dates, no taxonomy | |
| `design/fourth/` | Inbox + two borrowed ideas | current recommendation |

Each is standalone HTML/CSS/JS, no build step, phone and desktop share live
state, and each has a "Play the 3 flows" button.

## Settled — do not re-litigate

- Hosted web app, any browser, any device, over the internet
- One owner, one list, many devices. No collaboration, no second user.
- Data model ceiling: text, due date, priority, done. No tags.
- Out: offline sync, attachments, push, native apps, multi-user accounts
- Identity decided early; database engine deferrable behind a thin data layer
- Local dev must run the same engine as production
- Slice 3 (feel) must NOT follow slice 4 (data model)

## Bugs found — and how

Four real defects, **none found by reading code or trusting a self-report**:

1. Inbox silently discarded a parsed date — its headline feature was broken
2. Completion check had no class, so its SVG filled the card
3. `fitStage` double-scaled every frame in all four directions
4. Done cards rendered an empty circle — no done-state CSS existed at all

**Lesson: render it, drive it, read computed styles. Do not trust "verified".**
Owner spotted bug 4 by eye before the lead did.

## Design rules worth keeping

- Capture makes **no decisions**. Never infer a day from a bare time: typing
  "call mum at 9am" stays undated with the time retained. An invented overdue
  item nobody created is a guilt tax.
- Every graft must have a **distinct job**; two surfaces doing one job means one
  is always empty and reads as broken.
- Nothing typed is ever discarded.

## Open

- **Owner chose Direction 4**, then two independent reviews rejected the
  build. Chosen rebuild: Inbox spine, reversible filing, honest pin, day bar cut.
- **The advisor reordered the plan. Persistence comes first** — see below.
- Pending question to the owner, for each liked feature: *if we dropped it, what
  would you actually miss?* Distinguishes real preference from taste.
- The completion burst has an ON/OFF toggle; only the owner can settle whether
  it survives week two.

## Verified gaps nobody caught until late (advisor, confirmed by lead)

**STATUS: 2 and 3 are FIXED. Only 1 remains open.**

1. **The pin cannot fire on real data.** `carriedLongest()` filters
   `days > 0`; `addItem()` hardcodes `days: 0`; nothing anywhere assigns
   `.days`. No Date, no rollover. Every captured task is born at 0 and stays
   0. The "23 days" the owner liked was seed data behaving as authored.
2. **~~There is no delete.~~ FIXED.** Delete with a stacked, persisted undo
   bar that restores the item at its original index.
3. **~~There is no persistence.~~ FIXED.** Store, uid and undo stack persist
   to localStorage under `tasks.d4.v1`. Hydrate runs before first render;
   seeds only when the key is absent.

## Shipped since the reviews

- **Vertical day timeline**, show-only, mobile. Hours 06:00-23:00 down the
  page, rendering the same task card so completion stays one handler and one
  undo stack. Verified: completing from the clock and from the no-time group
  each push exactly one entry to the same stack, with no duplication.
- **complete() is a toggle** and shares the delete undo mechanism. Restores
  recorded prior state, not a blind flip.
- **Mobile only** at every width.
- **The horizontal day bar is CUT.** The owner liked it; it was cut because its
  marks were a second listing of the same tasks beside the timeline, which is
  the two-surface rule verbatim. A reconciling count header survives. It can
  come back as decoration, never as a task surface.
- **Gate logging exists.** Opening the day view increments `store.dayViews`
  keyed by real date, persisted. The timeline gate can now close itself on
  evidence rather than on hope.

## Older gaps, for the record

- **There was no delete and no persistence** when the reviews were written.
   Both listed above as fixed; kept here so a cold-start reader knows these
   were real and were closed, not invented.
- **There is still no server.** Everything is on one device. Losing that
   browser loses the data. This is what slice 0 solves, and it is also why
   automatic usage collection is not being built.

## Closed, kept for the record

These were real when written and are fixed now. Kept so a cold-start reader
knows they were found, not invented.

- **There was no delete** - the dataset would have been append-only and
  unerasable, against the "nothing typed is ever discarded" rule. Now fixed.
- **There was no persistence** - a refresh lost everything, so every judgement
  to date, including choosing Direction 4, was about 19 invented items rather
  than the owner's own tasks. Now fixed.

## Sequencing agreed with the advisor

**Standing instruction from the owner: check with the advisor whenever the lead
is not sure about anything.** Durable, and it outranks momentum.

The owner, on open product questions: *"I do not know too, we can figure out by
experiancing it."* Do not guess a preference and build it. Where the owner is
genuinely unsure, prefer the smallest build that lets experience answer it.

0. **Persistence + delete** on the deployed prototype. Gate: 10 real captures
   survive a refresh, nothing silently discarded.
1. **Undo on file and delete**, together. Gate: file then undo returns the item
   with context and time intact; a stray delete is recoverable.
2. **Pin trigger** — captured-at plus real age. Gate: an item from 3 days ago
   shows 3 days and survives a day boundary.
3. **Pin controls** — defer, dismiss. Gate: the pin can be set aside without
   being completed, and can never strand an item.

Bulk filing is deliberately NOT built yet: it is a volume answer to the 68-tap
finding, and real volume is unknown. Re-derive after step 0.

**The pin may be what dies at week two, not the day bar.** If the owner captures
three things a day, carried-longest is two days old by the end of week one, and
a two-day-old pin reads as nagging rather than signal.

Cutting the day bar is cheap to add back on real data. The spine and the pin are
not cheap to swap once habits form around them.

## Reversed: the day view is coming back

The owner asked for it back explicitly, as a **vertical timeline of hours** like
the "now" direction. That is not the horizontal day bar Direction 4 had. The
advisor and both reviewers advised cutting it, and the lead agreed. The owner
overruled all of us by using the app, which is a better basis than any review.

Open question, deliberately unanswered: should the timeline **create** by tapping
an empty hour, or only **show** where tasks sit. The owner does not know and
wants to experience it. Do not guess.

**Cut by review 2026-10-16, reinstated by owner use the same week.** Owner
evidence outranks review evidence here. Do not re-run this argument.

**Not a synthesis any more.** A vertical hour timeline borrowed from "now" is
returning, so the synthesis framing no longer describes the thing. When the
current slice lands, stop calling it Direction 4 - it becomes the app.

## Timeline slice: scope decided, question deferred to experience

**Show-only first.** Not because it is reversible, but because tap-to-create in
the "now" code requires a duration (30/60/120 chips) and auto-places at the next
free slot. Building it would pick duration and auto-placement before the
experiment could run, and both violate settled decisions.

Show-only is not blind: cards already carry a Set-time control, so the owner can
place an item today. The learnable question is whether placing from the card
leaves them wanting to place from the timeline.

**What the timeline must NOT do:**

- Create tasks that live only on the clock. Later placement must land in Inbox.
- Auto-place or default a time. Blank stays blank.
- Own a second completion **handler or undo history**. The test is not "is there
  a second control" but "is there a second handler". The timeline must render the
  same task card, so completion is one control in two positions. Completion is an
  action on the thing, not on its position.
- Carry duration, overlap, or a percentage that does not reconcile with the
  now-line. The day bar lied by five points.
- Become a planner: no drag, no reschedule, no next-free-slot suggestion.
- Own filing. That is Inbox's job.

**Gate:** one deliberate attempt on a day the owner knows has a gap, plus three
logged day-view opens. The app logs a day-view open with its date, so absence of
data is visible rather than silent. One session with intent beats a week of
ambient behaviour and does not require a habit to form first.

**Expiry:** the day-view shipping date is the named date. If the owner has not
opened the day view by then, close the question by default: show-only stays,
create is not built. Absence of reaching is weak evidence, not evidence of
wanting, and building create on absence would be guessing a preference. On
expiry the answer resolves to **not-wanted**, so the timeline ships as show-only
by decision rather than by inertia.

## Once a direction is chosen

Slice 0 is not "write the app". It is **foundation and reachability**: migrations
from commit one, deployed to a real URL, reachable from the owner's actual
phone, behind single-owner auth. It should be owner-testable before any feature.

## Verification habits that worked

- Drive flows in real headless Chrome, read state back, do not trust a report
- Render at desktop AND phone; responsive breakpoints hide bugs
- Read computed styles to confirm a visual state, not by eye
- `scripts/shot.sh <file> <out.png> [w] [h]` renders any prototype to PNG
