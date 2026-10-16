
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

- **Owner has not chosen a direction.** They liked mechanisms from all three
  originals; Direction 4 is the synthesis and the current recommendation.
- Pending question to the owner, for each liked feature: *if we dropped it, what
  would you actually miss?* Distinguishes real preference from taste.
- Falsifiable risk: if within a week the owner wishes the day bar were a grid,
  cut it and ship Inbox + carried-longest + context.
- The completion burst has an ON/OFF toggle; only the owner can settle whether
  it survives week two.

## Once a direction is chosen

Slice 0 is not "write the app". It is **foundation and reachability**: migrations
from commit one, deployed to a real URL, reachable from the owner's actual
phone, behind single-owner auth. It should be owner-testable before any feature.

## Verification habits that worked

- Drive flows in real headless Chrome, read state back, do not trust a report
- Render at desktop AND phone; responsive breakpoints hide bugs
- Read computed styles to confirm a visual state, not by eye
- `scripts/shot.sh <file> <out.png> [w] [h]` renders any prototype to PNG

