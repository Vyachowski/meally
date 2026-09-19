# One definition of CI

Type: grilling
Status: resolved
Map: ../map.md

## Question

The repo defines CI twice, and nothing keeps the two in step:

| | `.github/workflows/ci.yml` | `config/ci.rb` (run by `bin/ci`) |
|---|---|---|
| Runs where | GitHub Actions | your machine |
| rubocop | `lint` job | yes |
| brakeman | `scan_ruby` job | yes |
| bundler-audit | `scan_ruby` job | yes |
| importmap audit | `scan_js` job | yes |
| Rails tests | `test` job | yes |
| `bin/setup` | no | yes |
| seeds replant | no | yes |
| system tests | commented out | commented out |

Neither file references the other. The overlap is large enough that they look
interchangeable and different enough that they are not — `bin/ci` fails on Setup
and Seeds if Postgres is not running, while the workflow provides its own service
container.

`CONTRIBUTING.md` currently papers over this with a warning to change one and
check the other, which is a documented hazard rather than a fix.

Resolve which is the source of truth, and whether the other can be derived from
it or should simply be deleted. Options worth weighing:

- **Workflow calls `bin/ci`.** One definition, and what runs locally is exactly
  what gates the pull request. Costs the parallelism of four separate jobs, and
  the four required status checks in the ruleset (ticket 01) collapse into one —
  so the ruleset needs updating too.
- **Keep both, accept the drift**, and delete the warning from `CONTRIBUTING.md`
  in favour of a comment in each file pointing at the other.
- **Delete `config/ci.rb`** and keep the workflow as the only definition. `bin/ci`
  is a Rails 8.1 convenience; nothing forces its use.

Note the interaction with ticket 01: the ruleset requires exactly the four
contexts `lint`, `test`, `scan_ruby`, `scan_js`. Changing the job layout means
changing the required checks, or merges will block on checks that no longer
report.

## Answer

Resolved 2026-09-19: **deliberately deferred, not fixed.**

### What was verified first

`bin/ci` is referenced by nothing automated — not by a workflow, not by a hook.
Confirmed by grepping `.github/`, `.overcommit.yml` and the `Dockerfile`. The
merge gate is the five Actions checks and only those: `lint`, `test`,
`scan_ruby`, `scan_js`, `pr_body`.

So the duplication costs nothing today. It is two hand-maintained lists that can
disagree, and one of them currently governs nothing.

### The decision

Leave both. Revisit when it actually causes a problem rather than paying for a
restructure now. Collapsing them into one definition means a single serial job
(~50s becomes closer to 2 minutes), and rewriting the ruleset's required checks
from five contexts to two — real work, for a problem that has not yet bitten.

### What was fixed instead

`CONTRIBUTING.md` was making a false claim: it said a green `bin/ci` was *a
stronger signal than a green pull request*. That was wrong, and in a way that
would mislead — neither suite is a superset of the other:

- `bin/ci` additionally runs `bin/setup` and replants the seeds
- it cannot run `pr_body`, which needs a pull request body to read

The section now says plainly that GitHub Actions is the gate, that `bin/ci` is a
convenience nothing calls, and that a green `bin/ci` does not promise a green
pull request. The check table was also stale at four entries; it lists five.

### What would reopen this

- A failure that a green `bin/ci` let through, or a red `bin/ci` that turned out
  to be a false alarm — i.e. the drift biting for real
- Adding a step to one file and discovering later it was missing from the other
- `bin/ci` becoming part of anyone's actual habit, at which point the two lists
  disagreeing starts costing time

Recorded on the map under Not yet specified so the question stays visible.
