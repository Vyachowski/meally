# Retire `dev-docs/`

Type: task
Status: resolved
Blocked by: 04, 05, 08
Map: ../map.md

## Question

Once tickets 04 and 05 have drained `dev-docs/spec.md` into ADRs, the README,
`docs/deployment.md` and `.scratch/02-authentication/spec.md`, retire the directory:

1. **Confirm nothing is left behind.** Walk the sort table in ticket 03 and check
   each row actually landed somewhere — the ADRs from 04, the README and
   `docs/deployment.md` from 05, the feature spec from 08. Section 5 (domain
   model) and section 8 (CI) are deliberate discards, not misses.
2. **Delete `dev-docs/`.**
3. **Remove the `/dev-docs/` rule from `.gitignore`** — an ignore rule for a
   directory that no longer exists is a small lie about how the repo works.

Sequenced last on purpose. `dev-docs/` is untracked and ignored, so its contents
exist in exactly one place on disk and in no history — deleting before the
content has landed elsewhere is unrecoverable. Verify the destinations are
committed on `main` before removing anything.

A backup of the 336-line original was taken outside the repo while this map was
being worked; it is not a substitute for checking, and it disappears with the
session.

## Answer

Resolved 2026-09-19. `dev-docs/` is gone and its ignore rule with it.

### Verification before deleting

The directory held exactly one file, `spec.md`, byte-identical to the backup
taken when this map was charted — nothing else was hiding in there.

Every destination from ticket 03's sort table exists on `main`, and each of the
spec's distinctive facts was traced to a tracked file rather than assumed:

| Fact | Landed in |
|---|---|
| 128-hex `SECRET_KEY_BASE` | `docs/deployment.md` |
| `TARGET_PORT` / Thruster | `docs/deployment.md` |
| `meally_production_cache` | ADR-0003 |
| CVE-2015-9284 | `.scratch/02-authentication/spec.md` |
| `omniauth-rails_csrf_protection` | `.scratch/02-authentication/spec.md` |
| ~800-line retreat threshold | ADR-0004 |
| Bootstrap's 226 KB | ADR-0004 |
| FactoryBot's known cost | `CONTRIBUTING.md` |
| Parallel `meally_test-N` databases | README and `CONTRIBUTING.md` |
| `SECRET_KEY_BASE_DUMMY` | ADR-0002 |

`postgres:18` is the deliberate section 8 discard — it lives in `ci.yml` with its
reasoning. `assume_ssl` and `force_ssl` never appeared in the spec at all, so
nothing was lost there.

### One stale claim found and fixed

The README said the candidate native dependency for revisiting the
no-Docker-for-development decision was `image_processing`, needing `vips` or
`imagemagick`. Ticket 06 removed that gem, so the sentence had gone stale between
being written and this ticket. Rewritten to point at Active Storage, which is
when the dependency actually returns.

### Done

- `dev-docs/` deleted. It was untracked and ignored, so it existed in one place
  on disk and in no history — the verification above was the only safety net.
- The `/dev-docs/` rule removed from `.gitignore`: an ignore rule for a directory
  that does not exist is a small lie about how the repo works.
