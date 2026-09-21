# Credentials

Status: ready-for-agent

Secrets move back to the Rails default: `config/credentials.yml.enc` unlocked by
a master key, with the first user's email address and password among them. This
reverses [ADR-0002](../../docs/adr/0002-secrets-as-environment-variables.md) and
retires `.env` entirely.

## Why the reversal

ADR-0002 chose environment variables on rotation and blast-radius grounds. Both
arguments are sound and both are priced for a bigger project than this one. What
they cost here is a second mechanism: a `.env` file that every clone and every
git worktree has to be handed before anything runs, a template to keep in step
with it, a gem to load it, and a compose file that refuses to start without it.
One maintainer, one user, one deploy target — the Rails default is less to carry
and less to explain.

The trade is accepted with open eyes: the master key decrypts everything, and
the ciphertext is in git history forever. See Known cost.

## What moves and what does not

| Secret | Where it lives after | Why |
|---|---|---|
| `secret_key_base` | credentials | The Rails default; nothing external needs it |
| First user's email and password | credentials, per environment | Read by the seed, never by a test |
| `DATABASE_URL` | Railway variable, unchanged | Railway supplies it as a reference variable; it cannot be a file |
| `PORT` | Railway variable, unchanged | Platform routing, not a secret — see [`docs/deployment.md`](../../docs/deployment.md) |
| `RAILS_MASTER_KEY` | Railway variable | The one key that unlocks the rest |
| Local Postgres password | `compose.yaml` and `config/database.yml`, in the open | Not a secret — see below |

The one argument from ADR-0002 that survives intact is `DATABASE_URL`: it is a
reference to the Postgres service, so it follows the database when its
credentials change, and a copy in a file would go stale silently.

## The local database password is not a secret

Docker Compose reads its environment before Rails exists, so it cannot be handed
a value out of credentials. Rather than keep `.env` alive for one variable, the
local password becomes a plain literal in `compose.yaml`, with the same value as
the default in `config/database.yml`.

That is safe only as long as the container is genuinely local, and today it is
not quite: the port mapping binds `0.0.0.0`, so the development database is
reachable from anything on the same network. Narrowing the mapping to
`127.0.0.1` is part of the work, not an afterthought — it is what makes the
open literal defensible.

Production never reads either value. `DATABASE_URL` overrides the whole block.

## What the files end up being

- `config/credentials.yml.enc` + `config/master.key` — already exist, created
  2026-09-06 and unused ever since. Production and anything without its own file
  read these.
- `config/credentials/development.yml.enc` + `config/credentials/development.key`
  — new, holding the development user.
- **No test credentials file.** Fixtures keep their own test-only password
  (`SessionTestHelper::TEST_PASSWORD`) and a bcrypt digest, so the suite needs no
  key at all. CI therefore needs no new secret, and the `RAILS_MASTER_KEY` line
  already sitting commented in the workflow stays commented.

`secret_key_base` is not needed in development or test: Rails generates one into
`tmp/local_secret.txt` on first boot.

## Details that bite

**`.gitignore` does not cover the new key.** It ignores `/config/*.key`, which
matches `config/master.key` but **not** `config/credentials/development.key` —
one directory deeper. Without a new line, the development key is committable,
and a `git add -A` will take it.

**Asset precompilation is already safe.** The `Dockerfile` sets
`SECRET_KEY_BASE_DUMMY=1`, and that branch is taken before credentials are read,
so the build needs no key.

**Changing `secret_key_base` signs everyone out.** Session cookies are signed
with it. Moving the value into credentials must carry the *same* value that
production uses today, or every existing session and signed cookie is
invalidated on deploy.

**The seed must be idempotent.** It runs on an empty database and on a full one.
Find-or-create the user and update the password; never `create!` blindly.

## Decisions settled 2026-09-21

- **The decision record is rewritten in place.** The existing one is overwritten
  with the decision that holds today — no second record on the same subject, no
  "superseded by" header, no account of what changed. A decision record states
  what was decided, not the history of deciding it; git holds the rest. Keep it
  short.
- **The local database password is a tracked literal**, not a `.env` value — with
  the port mapping narrowed to localhost to earn it.
- **Tests do not read credentials.** The fixture keeps its own password, so CI
  needs no key and a contributor can run the suite without one.
- **The maintainer sets the dashboard values by hand** — Railway variables and
  any GitHub secret. Keys do not pass through an agent session.

## Known cost

The master key decrypts every secret in the file, and the encrypted file is in
git history forever: a leaked key compromises values that were already rotated
out. Two obligations follow, and they replace ADR-0002's:

- `config/master.key` and `config/credentials/development.key` live in the
  password manager. They are gitignored, so a lost laptop with no copy means a
  lost file.
- Rotating a credential is a commit, not a dashboard edit. That is the price
  paid for the simpler setup, and it is only tolerable while the secrets are few
  and change rarely.

## Open

- **How the production user gets seeded.** Running the seed on Railway needs a
  console or a one-off command against the deployed service. Ticket 04 settles
  it; until then the user is created by hand.
