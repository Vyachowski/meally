# Rewrite the README and write `docs/deployment.md`

Type: task
Status: resolved
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

## Answer

Resolved 2026-09-19. Three files written.

**`README.md`** replaces the generated Rails placeholder. It covers only what a
reader needs to run the thing: Ruby from `.ruby-version` (3.4.10), the three-line
local start (`cp .env.example .env`, `docker compose up -d`, `bin/setup`), why
the app is not itself in Docker, how to run the tests, and where deployment and
the rules live. It states plainly that the project is early stage and the domain
model is unsettled — true, and better said outright on a public repo than
discovered.

**`docs/deployment.md`** takes the operational Railway material: the variables
table with the password-manager obligation, why `DATABASE_URL` must be a
reference variable and is mandatory, why `PORT` is 80 (Thruster overwrites `PORT`
for the Puma child, so Railway's injected value never arrives), a pointer to
ADR-0003 for the four databases, the `RAILS_ENV`-vs-Railway-environment two-axes
table, and why there is no staging stand yet. Rationale is linked, not repeated —
the ADRs say why, this says what and how.

**`CONTRIBUTING.md`** gains a Tests section from spec section 7: model and
integration tests as the base, no controller tests, system tests only where a
real browser is required, fixtures rather than FactoryBot with its known cost
stated, and test-first for calculations but test-after for controllers and views.

Checked: every relative link in the README and the deployment doc resolves to a
file that exists.
