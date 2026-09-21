# 03 — Retire the `.env` file

**What to build:** someone who has just cloned the repository — or an agent that
has just made a fresh git worktree — starts the database and runs the test suite
without first being handed a file. No template to copy, no variable to fill in,
nothing that fails with a message about a missing value.

The local database password stops being a secret and becomes a plain tracked
literal, in the compose file and as the default the application connects with.
It only earns that treatment if the database is genuinely unreachable from
anywhere but this machine, so the port mapping is narrowed at the same time:
today it binds every interface, which puts a development database with a
published password on the local network.

The gem that reads the file goes with it. It exists to load a file into the
environment at boot; the deployed application never had one, because the
platform injects variables directly.

Nothing about the deployed application changes here, and CI gains no secret —
the suite still needs no key.

**Blocked by:** 01 — the decision has to be recorded before the file is removed.

**Status:** ready-for-agent

- [x] In a fresh clone, the database starts and the test suite passes with no
      file created or copied first
- [x] The development database refuses connections from any other machine on the
      network
- [x] No tracked document tells a reader to create or copy an environment file
- [x] Nothing in the application loads an environment file, and the gem that did
      is gone from the dependency list
- [x] CI is green without a new secret
- [x] The deployed application is unaffected — its variables are untouched

Context: [`../spec.md`](../spec.md) — see "The local database password is not a
secret" for why an open literal is acceptable and what makes it so.

Delivered by pull request #47, merged 2026-09-21. Verified in a fresh worktree
holding no environment file: the container came up, both databases were created
and the suite passed, with nothing copied first.

One thing worth knowing for any checkout that predates this: the container's
password is only applied when its volume is first created, so an existing
development database keeps the password it was born with and rejects the new
literal until the role is altered in place. Recreating the volume works too, at
the cost of the development data.
