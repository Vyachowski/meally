# Secrets live in Rails credentials

**Status:** accepted, 2026-09-21

Application secrets live in `config/credentials.yml.enc`, encrypted with
`config/master.key` and unlocked in production by `RAILS_MASTER_KEY`. Development
has its own encrypted file and key under `config/credentials/`. The first user's
email address and password are among the secrets, so `db/seeds.rb` can create
that user without a password reaching a console or a tracked file.

This is the Rails default, and for one maintainer and one deploy target it is
the cheapest thing that works: nothing to hand a fresh clone or a new git
worktree before it runs, and one place to look.

Two values stay environment variables, because they cannot be anything else:

- **`DATABASE_URL`** — Railway supplies it as a reference to the Postgres
  service, so the app follows the database when its credentials change. A copy
  in a file would go stale silently.
- **`RAILS_MASTER_KEY`** — the key that unlocks the rest.

`PORT` is a platform variable too, but it is routing rather than a secret. The
local Postgres password is not a secret either: it is a plain literal shared by
`compose.yaml` and `config/database.yml`, for a container that listens on
localhost only. Both are in [`docs/deployment.md`](../deployment.md).

## Consequences

- **The two key files live in a password manager.** They are gitignored, so a
  machine lost without a copy means a file nobody can read.
- **Rotating a secret is a commit and a deploy**, not a dashboard edit. That is
  tolerable while the secrets are few and change rarely; it stops being
  tolerable the moment they are neither.
- **A leaked key exposes every secret the file has ever held.** The ciphertext is
  in git history forever, so a leak means rotating everything in the file, not
  only the value that escaped.
- **Image builds need no key.** The `Dockerfile` sets `SECRET_KEY_BASE_DUMMY=1`,
  and that branch is taken before credentials are consulted.
