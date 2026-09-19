# One definition of CI

Type: grilling
Status: open
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
