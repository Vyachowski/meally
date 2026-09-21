# Dependabot policy and the open PR backlog

Type: grilling
Status: resolved
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

## Answer

Resolved 2026-09-19.

### Why six accumulated

Two causes, both now addressed. The config allowed 10 open pull requests per
ecosystem with no grouping, so every bump arrived as its own unread pull request.
And four of the six — #1, #2, #4, #14 — carried **stale check runs from a CI
layout that no longer exists**: a `system-test` job removed in `c6646d5`, and a
`test` job that failed because it predated
`c5b6059 fix: add db/schema.rb so CI can build the test database`. Those failures
were historical, but `test` is a required check, so the four had become
structurally unmergeable and looked broken. #15 and #16 were green all along.

### The policy

**Grouped minor and patch updates, auto-merged. Majors arrive alone and are read.**

`.github/dependabot.yml` now groups `minor` and `patch` for both ecosystems, so
one pull request arrives per ecosystem per week instead of up to ten. Majors are
deliberately excluded from the groups: they come as individual pull requests and
get human judgment, which is the only place that judgment is worth spending.
The open-pull-request limit drops from 10 to 5 — with grouping it should never be
approached, so hitting it is a signal something is wrong.

`.github/workflows/dependabot-auto-merge.yml` enables auto-merge on non-major
Dependabot pull requests. This does not bypass CI: auto-merge waits for the four
required checks in the `main` ruleset, so it only removes the final click once
they are green. Repository setting `allow_auto_merge` was enabled to make it
work.

The workflow uses `pull_request_target` and **deliberately does not check out the
pull request's code** — that event runs with write permissions against the base
repository, so running branch code would be a privilege escalation. It reads
metadata only.

### `image_processing` removed

Rather than taking the major bump in #14, the gem is removed from the Gemfile
entirely. It is a Rails default that nothing here uses: there is no Active
Storage attachment anywhere in `app/`, and the gem cannot function on this
machine regardless, since it needs `vips` or `imagemagick` and neither is
installed.

Carrying a dependency for a feature that does not exist means tracking its
majors forever. This is the same reasoning already applied to Kamal — delete it,
restore one line when it is actually needed. Removing it dropped 16 lines from
`Gemfile.lock`: the gem plus `mini_magick`, `ruby-vips` and seven `ffi` platform
variants.

### The backlog, after this lands

| PR | Action |
|---|---|
| #15 selenium-webdriver, #16 overcommit | green on current CI — merge |
| #1, #2, #4 GitHub Actions majors | `@dependabot rebase` to re-run CI, then merge by hand as majors |
| #14 image_processing | close — the gem is gone |

The three Actions bumps stay manual on purpose: they are majors, which is exactly
the case the policy reserves for a human.
