# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`. There is no
external tracker.

## Conventions

- One effort per directory: `.scratch/<NN>-<slug>/`, numbered from `01`
- The spec is `.scratch/<NN>-<slug>/spec.md`
- Tickets are one file each at `.scratch/<NN>-<slug>/issues/<NN>-<slug>.md`,
  numbered from `01` — never a single combined tickets file
- Comments and conversation history append to the bottom of the file under a
  `## Comments` heading
- When work comes from a ticket, the branch carries its number:
  `docs/02-flow-doc-location`. See [`CONTRIBUTING.md`](../../CONTRIBUTING.md) for
  the branch, commit, and pull request rules themselves.

## Efforts are numbered in the order they started

The number on an effort directory is chronological, not a priority: `01` is what
this project worked on first. A new effort takes the next free number, and
numbers are never reused or reshuffled afterwards — a directory listing is meant
to read as the timeline of the project, oldest first.

Ticket numbers inside an effort work the same way, except they are also
dependency order: blockers come first.

## `Status:` — two vocabularies, and which is which

Every issue and spec file carries a `Status:` line near the top. **It means
different things in the two kinds of file, so check which kind you are writing.**

**Wayfinder tickets** (a file under an effort that has a `map.md`) record a
lifecycle state:

| `Status:` | Meaning |
|---|---|
| `open` | Nobody is working on it. Combined with no unresolved `Blocked by:` line, this is what makes it frontier |
| `claimed` | A session has taken it. Set this **before** doing any work, so a concurrent session skips it |
| `resolved` | The answer is recorded under `## Answer` in the same file |

**Everything else** — feature specs and ordinary issues — records a triage role
instead:

| `Status:` | Meaning |
|---|---|
| `needs-triage` | Needs evaluating before anyone starts |
| `needs-info` | Waiting on more information |
| `ready-for-agent` | Fully specified, an agent can take it unattended |
| `ready-for-human` | Requires human implementation |
| `wontfix` | Will not be actioned |

When a skill names a triage role, use the string from the second table verbatim.

## When is a ticket finished

There is deliberately no `done` value, and the two kinds of file answer this
differently.

**A wayfinder ticket** is finished at `Status: resolved` — the answer is under
`## Answer` and the map's Decisions-so-far points at it.

**Every other ticket** is finished when its **acceptance criteria are ticked**.
`Status:` does not change. It is a triage role — who may take the work — not a
record of whether the work is done, so a shipped ticket still reads
`ready-for-agent`.

Tick the boxes when the work is **merged**, not when it is written.

## Ticket template

One ticket per file. Criteria are the completion mechanism, so every ticket has
them.

```markdown
# <NN> — <Title>

**What to build:** the end-to-end behaviour this ticket makes work, from the
user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

- [ ] Acceptance criterion
```

Write each criterion as **observable behaviour**, so it can be checked without
reading the implementation — "after signing in, the originally requested page is
restored", not "the concern stores the return path".

Keep file paths and code snippets out of tickets; they go stale. They belong in
the effort's `spec.md`, which the ticket links to.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<NN>-<slug>/`, creating the directory if
needed — the next free number.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the
ticket number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<NN>-<effort>/map.md` — the Destination / Notes /
  Decisions-so-far / Not-yet-specified / Out-of-scope body.
- **Child ticket**: `.scratch/<NN>-<effort>/issues/NN-<slug>.md`, numbered from `01`,
  with the question in the body. A `Type:` line records the ticket type
  (`research` / `prototype` / `grilling` / `task`); the `Status:` line uses the
  lifecycle vocabulary above.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked
  when every file it names is `resolved`.
- **Frontier**: the tickets that are `open`, unblocked and unclaimed; lowest
  number first.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set
  `Status: resolved`, then append a context pointer (gist + link) to the map's
  Decisions-so-far in `map.md`.
