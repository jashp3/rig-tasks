---
intent: A daily-use personal task app the owner actually keeps using.
status: design-exploration
---

# Mission: daily-task-app

## Intent

Build a personal task manager the owner opens every day and prefers to the
tools they currently resent. The bar is retention, not feature count.

## Current phase: design exploration

The owner does not yet know what the app should look like. Three structurally
different directions have been built as working prototypes and the pick comes
after. **No implementation starts until one is chosen.**

- `design/inbox/` — capture-first triage
- `design/now/` — clock / day timeline
- `design/threads/` — no lists, no dates, no taxonomy

## Constraints (decided, not open)

- Hosted web app, reachable from any browser on any device over the internet.
- One owner, one list, many devices. No collaboration, no second user.
- Data model ceiling: text task, due date, priority, done.
- Out: offline editing and sync engines, attachments and object storage, push
  notifications, native apps, multi-user accounts.
- Identity cannot be deferred. The database engine can be, provided a thin
  data layer sits in front of it from the first commit.
- Local development must run against the same engine as production. Developing
  on SQLite and deploying to Postgres is a bug found in production.

## Slices

### Slice 0 — Foundation and reachability

Migrations running from commit one, a thin data layer over them, deployed to a
real URL, reachable from the owner's actual phone, behind single-owner auth.
No user-facing features.

**Gate:** one migration applied on the hosted database, and the owner opens the
URL from their phone.

### Slice 1 — Vertical slice

Add a task, see it, complete it. On the real hosted stack, behind real auth, at
the real URL.

**Gate:** add a task on the laptop, see it on the phone.

### Slice 2 — The daily loop

Today as the default view, complete and un-complete, delete with recovery,
deliberate empty-state behaviour — especially the empty Today, which must not
read as broken.

### Slice 3 — Friction and feel

Keyboard shortcuts, fast capture, fast edit, dark mode, motion, typography.
Largest slice by hours and the retention slice. Design must be in the room
before it is coded.

### Slice 4 — Time and shape

Due dates, priorities, Upcoming. Only now do recurrence (fixed interval only)
and search earn their place.

**Hard ordering rule: slice 3 must not follow slice 4.** Building the full data
model before the feel produces a correct app nobody wants to open.

## Risks on record

- **The lost idea.** Capture friction is the most likely cause of abandonment,
  and the owner is often on a phone only.
- **The empty first run.** Day one is a beautifully designed empty box with no
  history. Seed it; do not let it read as broken.
- **The guilt archive.** Capture always outruns completion. Without a Done view
  that feels like progress, the app becomes a record of failure.
- **No reliable daily launch.** "Use it every day" means one dependable way in,
  every day.

