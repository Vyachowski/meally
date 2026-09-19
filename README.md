# Meally

A Ruby on Rails application for tracking weight and nutrition.

**Early stage.** The domain model is not settled and the application is still
close to a bare Rails skeleton; what is settled is the infrastructure around it —
deployment, environments, CI and the contribution rules.

Rails 8.1 with Hotwire, importmap and Propshaft. Postgres. No CSS framework —
see [ADR-0004](docs/adr/0004-no-css-framework.md).

## Running it locally

Ruby comes from `.ruby-version` (3.4.10); any version manager that reads it will
do. **Postgres runs in Docker, the application does not** — see below for why.

```sh
cp .env.example .env     # then set DB_PASSWORD
docker compose up -d     # Postgres 18 on localhost:5434
bin/setup                # installs gems, prepares the database, starts the server
```

After the first run, `bin/dev` starts the server on its own.

`.env` is read by both Docker Compose and Rails (through `dotenv-rails`), so the
database credentials have a single source. `DB_PASSWORD` has no default on
purpose — a fallback here would also apply in production.

### Why the app isn't in Docker

Ruby is already pinned by `.ruby-version`, so the reproducibility problem a
container would solve is solved. Running the app on the host avoids prefixing
every command with `docker compose exec`, avoids slow bind mounts on macOS, and
avoids a second copy of the gems — the editor's LSP and rubocop need them on the
host regardless. The production `Dockerfile` is unaffected; Railway builds it.

Worth revisiting if a second developer joins, or if a native dependency turns
painful on macOS. The likeliest candidate arrives with Active Storage, whose
`image_processing` gem needs `vips` or `imagemagick` — neither of which is
installed here, which is part of why that gem was removed until it is actually
needed.

## Tests

```sh
bin/rails test
```

Minitest, with fixtures. Tests run in parallel across your cores, each worker
getting its own database (`meally_test-0`, `meally_test-1`, …), so Postgres must
be up.

To run everything CI runs — rubocop, the three security scans, the tests and a
seeds replant:

```sh
bin/ci
```

## Deployment

A push to `main` triggers a Railway build of the `Dockerfile` and a rollout.
Configuration, environment variables and the environment model are in
[`docs/deployment.md`](docs/deployment.md).

## Documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — branch, commit and pull request rules
- [`docs/adr/`](docs/adr/) — why things are the way they are
- [`docs/deployment.md`](docs/deployment.md) — Railway, variables, environments
- [`AGENTS.md`](AGENTS.md) — additional rules for coding agents
