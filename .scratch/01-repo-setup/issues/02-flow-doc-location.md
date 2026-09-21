# Where the developer-flow rules live

Type: grilling
Status: resolved
Map: ../map.md

## Question

The branch, commit, and PR rules are decided but currently exist only in this
map. They need a tracked home, and the repo already has four plausible ones with
different readerships:

- **`README.md`** — today the untouched Rails stub. Read by anyone landing on
  the now-public repo.
- **`CONTRIBUTING.md`** — does not exist. The conventional home for exactly these
  rules, and GitHub surfaces it in the PR UI. Arguably ceremonial for a repo with
  one human contributor.
- **`AGENTS.md`** — exists, and is the file coding agents actually read. Today it
  only points at `docs/agents/*` for skill configuration.
- **`docs/development.md`** — a new file alongside the existing `docs/agents/`.

The decision is complicated by two audiences needing the same rules: a human
reading the repo, and an agent that must follow them without being told.
Duplicating the rules across two files guarantees drift; a single file means one
audience reads a document not addressed to them.

Resolve: which file holds the rules, what the other files say instead (a pointer,
or nothing), and whether the flow rules and the agent instructions are one
document or two.

Then write it — this map carries execution.

## Answer

Resolved 2026-09-19. Two documents, split along the seam between shared rules and
agent-only addenda, so nothing is stated twice and there is nothing to drift.

**`CONTRIBUTING.md` is the single source of truth** for the flow rules: hook
installation, the PR-only rule and its absent hotfix exception, branch naming,
Conventional Commits, rebase-only history, branch cleanup, and the four required
CI checks.

Chosen over `AGENTS.md` and a new `docs/development.md` because the repo is
public now and `CONTRIBUTING.md` is the one location GitHub actively surfaces —
the Contribute sidebar and the pull request UI both link it, so a drive-by
contributor finds it without being told. Putting the rules in `AGENTS.md` would
optimise for agents, who follow a pointer reliably, at the expense of the
audience who will not. A `docs/development.md` adds a hop for both and invents a
location this repo does not use: `docs/` holds referenced material
(`agents/`, and soon `adr/`), not primary docs.

**`AGENTS.md` gains a `## Developer flow` section** carrying only what is
genuinely agent-specific — work in a worktree, never merge to `main`, claim the
`.scratch` ticket before starting, install hooks in a fresh worktree — plus an
instruction to read `CONTRIBUTING.md` before the first commit. The pointer is
phrased as an instruction rather than a footnote, because an agent skims a link
it is not told to follow. This matches the file's existing convention of a short
agent-facing summary plus a pointer to the detail.

**The README pointer is deferred to ticket 05**, which already lists it. Adding a
single link to a file that is still the generated Rails placeholder would be
half an edit; the rewrite covers it.
