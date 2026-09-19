# Secrets live in environment variables, not Rails credentials

**Status:** accepted, 2026-09-06

Production secrets are Railway environment variables; locally they come from
`.env` via `dotenv-rails`. `config/credentials.yml.enc` is not used for them, and
`RAILS_MASTER_KEY` is deliberately never set.

This is a deviation from the Rails default, so it is worth saying why. Rails
itself resolves the variable first — `secret_key_base` reads `ENV` before falling
back to credentials — and four things follow from that:

1. **Rotation.** Changing a credential means editing a file, committing, pushing
   and redeploying: a secret change becomes a code change. A variable is changed
   and the process restarted.
2. **Blast radius.** `master.key` decrypts everything, and the ciphertext is in
   git history forever. If the key leaks, secrets that were already rotated out
   are compromised too.
3. **Variables are unavoidable anyway.** `RAILS_MASTER_KEY` itself would have to
   be a Railway variable, so credentials add a layer without removing the
   dependency.
4. **`DATABASE_URL` cannot live in credentials at all** — Railway supplies it as
   a reference variable.

Asset precompilation is unaffected: the `Dockerfile` sets `SECRET_KEY_BASE_DUMMY=1`,
and that branch is taken before credentials are ever consulted.

## Consequences

- **Standing obligation: keep a copy of every production secret in a password
  manager.** The values exist only in the Railway dashboard, so losing access to
  the account otherwise means losing the secrets.
- A `staging` environment costs nothing extra when it arrives — different values
  for the same variable names, rather than a second encrypted file and a second
  key.
- `config/credentials.yml.enc` and `master.key` remain in the repo, unused and
  harmless. If nothing has needed them after a reasonable interval, delete them.
