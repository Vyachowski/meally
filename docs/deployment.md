# Deployment

Meally runs on Railway. A push to `main` triggers a build of the repository's
`Dockerfile` and a rollout — the same image that is built locally. Postgres is a
Railway service. The reasoning is in
[ADR-0001](adr/0001-deploy-to-railway.md).

## Environment variables

Production secrets are Railway environment variables, not Rails credentials — see
[ADR-0002](adr/0002-secrets-as-environment-variables.md). Set them in the Railway
dashboard.

| Variable | Value |
|---|---|
| `SECRET_KEY_BASE` | `bin/rails secret` output, 128 hex characters. Set once |
| `DATABASE_URL` | `${{ Postgres.DATABASE_URL }}` — a reference, not a copy |
| `PORT` | `80` — see below |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | once OAuth exists |

`RAILS_MASTER_KEY` is **not** set and is not needed.

> **Keep a copy of every value in a password manager.** They exist only in the
> Railway dashboard; losing access to the account otherwise means losing the
> secrets.

`DATABASE_URL` must be a reference variable rather than a pasted string, so the
app follows the database when its credentials change. It is also **mandatory**:
`production` inherits the `default` block in `config/database.yml`, whose host
and port are the local Docker values, so without `DATABASE_URL` the app would try
to reach `localhost:5434` and fail.

## Why `PORT` is 80

Thruster, which fronts Puma in the generated `Dockerfile`, listens on `HTTP_PORT`
(default **80**) and starts Puma on `TARGET_PORT` (3000) — **overwriting `PORT`
for the child process**. Railway's injected `PORT` therefore never reaches Puma,
while from the outside Thruster is waiting on 80.

Railway uses `PORT` for healthchecks and routing, so it has to name the port
Thruster is actually listening on. Hence `PORT=80`.

## The four databases

Rails 8 needs a primary database plus one each for Solid Cache, Solid Queue and
Solid Cable, while Railway supplies a single `DATABASE_URL`. The three Solid
databases derive their URLs from it by rewriting the database name, and they must
exist on the Postgres service. Getting this wrong produces a green deploy that
dies at the first cache write or enqueued job — the details and the three
non-obvious constraints are in
[ADR-0003](adr/0003-derive-solid-database-urls.md).

## Environments

Two things that share a name and are easy to conflate:

| Concept | What it is | Values |
|---|---|---|
| `RAILS_ENV` | the Rails application environment | `development` / `test` / `production` |
| Railway environment | an isolated set of services | `production`, later perhaps `staging` |

They are **different axes**. A Railway `staging` environment would still run
`RAILS_ENV=production` — otherwise assets, caching and log levels all change and
it stops resembling production.

| `RAILS_ENV` | Runs where | Database |
|---|---|---|
| `development` | your machine | Postgres in Docker Compose |
| `test` | your machine and GitHub Actions | locally the same container, a separate database; in CI a service container |
| `production` | Railway | the Railway Postgres service |

### There is no staging environment

Tests are a run, not a place: they happen on your machine and in GitHub Actions.
A separate stand becomes worth having when other people use the app — at that
point, a Railway `staging` environment with its own database, deploying from a
branch, still running `RAILS_ENV=production`. Not before: today the only user is
the author, and there is nobody to protect the real thing from.

## Not yet decided

- **A custom domain.** Railway serves the app on its own subdomain for now.
- **The OAuth redirect URI**, which depends on that domain. It is `localhost:3000`
  today.
