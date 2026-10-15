---
from: orch-advisor@factory
to: orch-lead@factory
re: Scope revision after the owner's two answers
status: information — lead may decline any of it
---

ADVISORY 2 from orch-advisor. You are right that A0 landed and I am revising.
One correction to my own previous message first: I said search and recurrence were
now-or-never schema decisions. Given hosted multi-device they are still schema
decisions but they are NO LONGER urgent — see (1). I over-dramatised that.

## 1. Architecture decision space, and what is safe to defer

**The one decision you cannot defer: IDENTITY.** The owner said any device. That
means either accounts, or one shared secret that every device presents.
Everything else can move later; this cannot, because retrofitting auth means every
route, every query and every session gets touched. Decide it early and cheaply. For
a single owner, the cheap correct answer is a single-owner passwordless or
shared-passphrase model, not a user table. Do not build a multi-user accounts system
the owner will never use.

**The decision you can safely defer: the database engine.** This is the good news in
your update. A hosted task app's data model is roughly tasks, and maybe
due_date / priority / recurrence / position. Every mainstream hosted engine runs that
comfortably. Pick whatever the deployment target makes easiest and treat it as
replaceable. The thing that actually protects you is an ORM or a thin data layer
NOW, not the engine — so a later swap is a config change, not a rewrite. That is the
whole deferral mechanism.

So: hosted database, and local dev against a throwaway instance of the SAME engine, so
local and hosted behave identically. Do not develop against SQLite and deploy to
Postgres; that is a class of bug you find in production.

**What the design can actually force — check each prototype against this list before
the owner picks:**

- Does the direction assume offline edits that queue? That forces a sync engine. Out of
  scope. Any prototype implying it loses on cost, not taste.
- Does it need a background service or a native install? Out of scope for a browser app.
- Does it need images or attachments on tasks? That forces object storage, which is
  real infrastructure. If a direction shows thumbnails, it just got more expensive —
  know that before it wins on looks.
- Does it need push notifications or browser background sync? Out of scope.
- Does it assume more than one person, or shared lists? Out of scope, and the owner
  did not ask for it.

If all three directions stay inside "text task, due date, priority, done", the design
has not constrained your architecture and you are free.

**Tell design this now**, before they finish: no offline/queueing story, no
attachments, no push, no collaboration, no accounts-in-the-UI. If a direction is
already leaning that way, better to know now than to unpick it after the owner falls
in love with it. This is the design-forces-something risk you asked about, and it is
cheap to close right now.

## 2. Revised slices

You are right that durability moves to the front. But it is not "slice 0-adjacent", it
IS slice 0 — and hosting collapses into it. New order:

**SLICE 0 — FOUNDATION AND REACHABILITY.** Repo, environment config, schema and
migrations running from commit one, the data layer behind the ORM, DEPLOYED AND
REACHABLE ON A REAL URL FROM A REAL DEVICE, behind whatever single-owner auth you
chose. Nothing user-facing yet. Gate: one migration applied on the hosted database,
and the owner can reach the URL from their phone.

**SLICE 1 — VERTICAL SLICE.** Add a task, see it, complete it. On the real hosted
stack, behind real auth, at the real URL. Days, not weeks. Owner-testable
immediately: add a task on the laptop, see it on the phone.

**SLICE 2 — THE DAILY LOOP.** Today as default view, complete / un-complete, delete
with recovery, empty-state behaviour. Still my predicted failure point in week two —
the empty Today on a Sunday night. Build it in deliberately.

**SLICE 3 — FRICTION AND FEEL.** Keyboard shortcuts, fast capture, fast edit, dark
mode, motion, typography. The largest slice by hours and the retention slice. Design
lands here, so design must be in the room before it is coded, not after.

**SLICE 4 — TIME AND SHAPE.** Due dates, priorities, Upcoming. Now recurrence and
search earn their place.

**Durability is no longer a slice.** It is the exit condition of slice 0: migrations
work, there is a documented restore that has been performed once, and the app is
deployed. What remains at the end is ops — monitoring, a runbook, a domain — not a
fifth slice.

**Standing unchanged from advisory 1:** do not let slice 4 precede slice 3. And the
retention risks in (d) of that message all still apply — they were never local-only.
D1 is worse now, not better: the owner is on a phone, so capture friction is the thing
most likely to kill this, and it argues for a design with capture-first thinking over
list-first thinking. That is worth putting in front of design as a preference, not a
constraint.

## 3. Extract "difficult to work with" — but not yet

Do not ask about incumbents before they have looked. You are right, and asking first
anchors them on tools they already resent.

Ask it AFTER, attached to the prototypes, not to the old tools. Two questions, and the
second is the one that matters:

1. "Of these three, which felt least annoying to use?"
2. "In the one you picked, at what exact moment did it start to feel like work?"

Question 2 is the real gold. It converts a global dissatisfaction into a named moment,
and a named moment is something you can design against and test for. Ask it in the same
sitting as the pick.

**One flag on the design brief.** The owner does not know what it should look like.
That is a genuine risk of the exercise: if design delivers three variations on the same
idea, the owner picks on taste between near-identical things and learns nothing. Tell
dev.design the three directions must differ in STRUCTURE, not palette — one
capture-first, one calendar/time-first, one list-first. If they come back looking like
three themes of the same layout, send them back.

**And a stopping rule worth having now:** if after the review the owner still cannot
choose, that is information, not failure. Do not let an undecided owner silently stall
the team. Fall back to the most structurally conservative direction, say so explicitly,
and revisit after they have used it for a week. Real usage beats more options.

## 4. Getting the prototypes in front of the owner — I checked the box

What I verified on this host:

- No display server at all (no DISPLAY, no Wayland, no herdr). Headless. So "open it
  in a browser here" does not exist as a route.
- There IS a public IP on this host, and outbound internet works.
- There is NO rig mechanism for this. No image surface, no file-share surface, no TUI
  file viewer. The owner's own surface is a terminal. Files must be served over the
  network or pulled out. Nobody is watching that terminal.

So the honest answer is: **files must be either served over the network or pulled
out.** There is no third mechanism I can find.

BUT — and this is the useful part — **do not treat this as a separate problem from
deployment.** The owner just told you they want this reachable from a phone over the
internet. You are going to have to solve exactly this for the real app in slice 0.
Solve it once, now, for a static file instead of an app, and slice 0 is already
half-done.

**Recommended route, in order:**

1. Keep the prototypes STANDALONE — one self-contained .html each, no build step, no
   local assets, so they can be hosted anywhere with zero ceremony.
2. Ask the owner ONE question: "do you want to pick designs by opening a link on your
   phone, or by looking at files on your machine?" That single answer picks the route
   and costs them nothing.
3. If a link: deploy the prototypes to a static host now. This doubles as your first
   deployment, proving the hosting path before slice 0 needs it. Note honestly that
   static hosting is NOT the same as the app's eventual hosting — app hosting needs a
   server runtime — but it de-risks the link-and-reachability mechanics, which is the
   part that has actually bitten you.
4. If files: they pull them. Give exact scp/rsync, or tell them to open the file from
   the shared path. Least magical, but owner-hostile if they are on a laptop.

**Do not, on your own initiative, expose this container's directory over the network.**
I tried to verify reachability by serving the project folder and the safety layer
blocked me, correctly: that publishes whatever else lives in that tree to anyone who
can reach the port. If you want to explore that route it needs the owner's explicit
go-ahead and a scope-limited document root containing ONLY /root/rigs/tasks/design —
never the repo root, which will hold credentials and env files as the app grows.

Practical unblock while the owner decides: design should deliver, and you keep them in
the repo. The exposure question only has to be solved when the owner is actually ready
to look.

## Small correction to your update

You said "local SQLite as the architecture is dead". Agreed. You also implied my
out-of-scope lines about hosting and accounts all come off — right, but do NOT flip to
"collaboration is now cheap". It is not. One owner, one list, more devices. Same data
model, more ways to reach it. Multi-user is still out of scope and stays out.

## Priority if short on time

1. Tell design the architecture constraints NOW (section 1).
2. Fix slice 0 (section 2).
3. Ask the owner the link-or-files question (section 4).

The rest can follow.