# Deployment

Meally runs on Railway. A push to `main` triggers a build of the repository's
`Dockerfile` and a rollout — the same image that is built locally. Postgres is a
Railway service. The reasoning is in
[ADR-0001](adr/0001-deploy-to-railway.md).

## Environment variables

Production secrets live in Rails credentials — see
[ADR-0002](adr/0002-secrets-in-rails-credentials.md). A few values have to be
Railway environment variables regardless; set those in the Railway dashboard.

| Variable | Value |
|---|---|
| `RAILS_MASTER_KEY` | the contents of `config/master.key`, 32 hex characters |
| `DATABASE_URL` | `${{ Postgres.DATABASE_URL }}` — a reference, not a copy |
| `PORT` | `80` — see below |

Three, and that is all of them. Everything else the application needs is in
`config/credentials.yml.enc`, which the master key opens.

> **Keep a copy of `config/master.key` in a password manager.** The file is
> gitignored and Railway hides the value once saved, so those two copies are the
> only ones that exist. Lose both and the encrypted file is unreadable.

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

## The first user

There is no sign-up form. The application has one user, and it comes from the
credentials of the environment it runs in — never from a password typed into a
console. Put it there first:

```sh
bin/rails credentials:edit                              # production
bin/rails credentials:edit --environment development    # your machine
```

```yaml
user:
  email_address: you@example.com
  password: a long one
```

`db/seeds.rb` creates that user. Locally `bin/setup` runs it while preparing the
database, and `bin/rails db:seed` runs it on its own. In production the database
already exists, so the seed is run once inside the running container:

```sh
railway ssh --project meally --environment production --service Rails -- bin/rails db:seed
```

The first `railway ssh` asks to register an SSH key with Railway. The seed is
idempotent — run it again and it prints that the user is already seeded, rather
than failing or resetting anything. To change the password later, edit the
credentials and run the seed again.

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
