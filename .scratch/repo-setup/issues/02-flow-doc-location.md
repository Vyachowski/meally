# Where the developer-flow rules live

Type: grilling
Status: open
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
