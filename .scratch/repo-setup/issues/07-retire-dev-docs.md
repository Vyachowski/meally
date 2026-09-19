# Retire `dev-docs/`

Type: task
Status: open
Blocked by: 04, 05, 08
Map: ../map.md

## Question

Once tickets 04 and 05 have drained `dev-docs/spec.md` into ADRs, the README,
`docs/deployment.md` and `.scratch/authentication/spec.md`, retire the directory:

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
