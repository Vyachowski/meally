# Sort `dev-docs/spec.md` into its destinations

Type: grilling
Status: open
Blocked by: 02
Map: ../map.md

## Question

`dev-docs/spec.md` is 336 untracked Russian lines across eight sections. It was
settled while charting that it gets split rather than moved wholesale: durable
trade-offs become ADRs, operational how-to becomes README or `docs/` prose, and
the rest is discarded. It was also settled that only the expensive decisions get
backfilled as ADRs, not all six candidates.

What is not settled is the sort itself. Go section by section and assign each a
destination — ADR, README, a `docs/` page, or discard:

1. Deploy — Railway (incl. secrets-as-env-vars, Railway variables, the port
   decision, the Solid Cache/Queue/Cable database URLs)
2. Environments (`RAILS_ENV` vs Railway environment; no separate test stand)
3. Local environment (services in Docker, app on the host)
4. Authentication (Google OAuth over Rails sessions) — note this describes work
   not yet done, which may make it a spec rather than a decision record
5. Domain model — explicitly undecided; ruled out of scope for this map
6. Frontend and CSS (no framework, Pico CSS, quality bar per stage)
7. Tests (Minitest, fixtures over FactoryBot, test-first for calculations)
8. CI — GitHub Actions (pinned Postgres image, the removed `system-test` job)

Sections 4 and 6 are the awkward ones: they record intentions about future work
rather than decisions already made, and an ADR for an unimplemented decision ages
badly.

Output: a table mapping each section to its destination, with whatever is
discarded named explicitly so it is a choice and not an oversight. Feeds tickets
04 and 05, and settles the fate of `dev-docs/` itself.

Blocked by 02 because "README or a `docs/` page" cannot be answered before the
doc layout is decided.
