# Dependabot policy and the open PR backlog

Type: grilling
Status: open
Blocked by: 01
Map: ../map.md

## Question

Six dependabot PRs are open, the oldest from 2026-08-01:

| # | Bump | Opened |
|---|---|---|
| 16 | overcommit 0.72.0 → 0.73.0 | 2026-09-12 |
| 15 | selenium-webdriver 4.48.0 → 4.49.0 | 2026-09-12 |
| 14 | image_processing 1.14.0 → 2.1.0 (major) | 2026-09-05 |
| 4 | actions/checkout 6 → 7 | 2026-08-01 |
| 2 | actions/cache 4 → 6 | 2026-08-01 |
| 1 | actions/upload-artifact 4 → 7 | 2026-08-01 |

Two things to resolve.

**The policy.** `.github/dependabot.yml` runs weekly with a limit of 10 open PRs
per ecosystem, which is how six accumulated unread. Options include auto-merging
patch and minor bumps once CI is green, grouping updates so one PR arrives per
ecosystem per week, lowering the open-PR limit so the backlog caps itself, or
leaving it manual and reviewing weekly. Auto-merge interacts with ticket 01: it
works only when the required checks are the gate, and under rebase-only merging
dependabot branches must stay rebaseable.

**The backlog.** Merge or close all six. `image_processing` 1.14 → 2.1 is the one
needing judgment — a major bump, and `dev-docs/spec.md` §3 already flags that the
gem will need `vips` or `imagemagick` installed, neither of which is present
locally. The gem is currently unused, which makes the bump either free or
pointless depending on whether Active Storage is actually coming.

Blocked by 01 so that clearing the backlog doubles as the first live test of the
branch policy: these six PRs are the first merges that have to pass through it.
