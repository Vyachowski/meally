# Derive the Solid database URLs from `DATABASE_URL`

**Status:** accepted, 2026-09-07

Rails 8 wants four databases — primary plus one each for Solid Cache, Solid Queue
and Solid Cable — while Railway supplies exactly one `DATABASE_URL`. In
`config/database.yml`, each of the three Solid entries builds its own `url:` by
parsing `DATABASE_URL` and replacing the database name:

```erb
url: <%= ENV["DATABASE_URL"] && URI.parse(ENV["DATABASE_URL"]).tap { |u| u.path = "/meally_production_cache" }.to_s %>
```

This looks laborious enough that a future reader will try to simplify it. Three
things, all established the hard way, say why the obvious simplifications fail.

1. **`DATABASE_URL` applies to the primary database only.** The other three
   silently keep the `default` block's values — which are the local Docker
   credentials, `localhost:5434`. This is what broke the first deploy at
   `db:prepare`.
2. **All four cannot share one database.** Once the primary schema is loaded the
   database is non-empty, so Rails takes the migration path for cache, queue and
   cable — and no `db/*_migrate` directories exist. The Solid tables are simply
   never created, the app deploys green, and it dies later at the first cache
   write or enqueued job.
3. **An explicit `database:` key does not override the name in `url:`.** So the
   three cannot be separated that way; the name has to be rewritten inside the
   URL itself.

## Consequences

- The three Solid databases must exist on the Postgres service. They are not
  created by the app.
- Failure mode if this regresses is **silent**: a green deploy that fails at the
  first cache read or background job, not at boot. Any change here should be
  verified by actually exercising a job and a cache write.
- The database names are hardcoded to `meally_production_*`, so the production
  Postgres instance is assumed to host all four.
