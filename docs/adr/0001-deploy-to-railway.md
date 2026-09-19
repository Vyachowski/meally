# Deploy to Railway

**Status:** accepted, 2026-09-06

Meally deploys to Railway: a push to `main` triggers a build of the repository's
`Dockerfile` and a rollout. Railway also provides the Postgres service, wired to
the app through a reference variable rather than a copied connection string, so
the two stay in step when credentials change.

Kamal — which Rails 8 generates by default — was removed in favour of this. Kamal
means owning a server, its TLS and its certificates, and that ops work is
deliberately deferred until it is actually needed rather than paid for upfront.
The generated multi-stage `Dockerfile` works as-is on Railway, so the same image
runs locally and in production.

## Consequences

- `config/deploy.yml`, `.kamal/`, `bin/kamal` and the gem are gone, along with
  nine transitive dependencies. Recoverable from history if the decision is
  reversed.
- Nothing in `config/database.yml` needs changing for the primary database:
  Rails merges `DATABASE_URL` over it. The other three databases are a different
  story — see [ADR-0003](0003-derive-solid-database-urls.md).
- The app is only reachable at a Railway-provided subdomain. A custom domain is
  still unchosen.
