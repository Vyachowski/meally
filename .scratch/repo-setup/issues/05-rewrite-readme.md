# Rewrite the README

Type: task
Status: open
Blocked by: 02, 03
Map: ../map.md

## Question

`README.md` is still the generated Rails placeholder — the one that lists "Things
you may want to cover". The repo is now public, so this is the first thing a
reader sees.

Write a real one covering what ticket 03 routes here. At minimum the facts that
already exist and are currently undocumented:

- Ruby version comes from `.ruby-version` / mise
- Postgres runs in Docker via `compose.yaml` on port 5434; the app runs on the
  host, not in a container
- `.env` via `dotenv-rails` for local config; `.env.example` is the template
- How to run the test suite, and that tests parallelize into `meally_test-N`
  databases
- Deployment: push to `main` → Railway builds the `Dockerfile`
- A pointer to wherever ticket 02 put the contribution rules

Keep it to what a reader needs to run the thing. Rationale belongs in the ADRs
from ticket 04 — the README says what and how, the ADRs say why.
