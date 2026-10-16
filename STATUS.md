
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

1. **The pin cannot fire on real data.** `carriedLongest()` filters
   `days > 0`; `addItem()` hardcodes `days: 0`; nothing anywhere assigns
   `.days`. No Date, no rollover. Every captured task is born at 0 and stays
   0. The "23 days" the owner liked was seed data behaving as authored.
2. **There is no delete.** No remove, no trash. With "nothing typed is ever
   discarded" as a rule plus a real database, the dataset would be
   append-only and unerasable.
3. **There is no persistence.** No localStorage, no fetch, no XHR. State is a
   hardcoded fixture; a refresh loses everything. **The owner has never
   captured a real task, so every judgement to date — including choosing
   Direction 4 — is about 19 invented items.**

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

## Once a direction is chosen

Slice 0 is not "write the app". It is **foundation and reachability**: migrations
from commit one, deployed to a real URL, reachable from the owner's actual
phone, behind single-owner auth. It should be owner-testable before any feature.

## Verification habits that worked

- Drive flows in real headless Chrome, read state back, do not trust a report
- Render at desktop AND phone; responsive breakpoints hide bugs
- Read computed styles to confirm a visual state, not by eye
- `scripts/shot.sh <file> <out.png> [w] [h]` renders any prototype to PNG
