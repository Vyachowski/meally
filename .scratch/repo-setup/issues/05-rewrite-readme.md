# Rewrite the README and write `docs/deployment.md`

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

## Also: `docs/deployment.md`

Ticket 03 routes the operational Railway material here rather than into the
README, so that the README stays short enough to read end to end. Write it from
spec sections 1 and 2:

- The Railway variables table (`SECRET_KEY_BASE`, `DATABASE_URL` as a reference
  variable rather than a copy, `PORT`, the Google OAuth pair when it arrives),
  and the standing obligation to keep a copy in a password manager
- **`PORT=80`** — Thruster listens on `HTTP_PORT` (default 80) and runs Puma on
  `TARGET_PORT`, overwriting `PORT` for the child process, so Railway's injected
  `PORT` never reaches Puma. Railway uses the variable for healthchecks and
  routing, which is why it must be 80
- `RAILS_ENV` and Railway environments are **different axes** — a Railway
  `staging` environment would still run `RAILS_ENV=production`
- Where each environment's database lives, and that there is no separate test
  stand — tests run locally and in GitHub Actions
- That `RAILS_MASTER_KEY` is deliberately not set
