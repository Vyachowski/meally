# Lock down `main`

Type: task
Status: open
Map: ../map.md

## Question

Make the branch policy real on GitHub, now that the repo is public and rulesets
are available (the API returned `[]` instead of 403 after the visibility flip).

Nothing here is undecided — this ticket executes the policy settled while
charting. Work to do:

1. **Repository merge settings.** Disable merge commits and squash-merge, leave
   rebase-merge enabled, and turn on delete-branch-on-merge. Current state is
   all three allowed with `deleteBranchOnMerge: false`.
2. **A ruleset on `main`** that refuses direct pushes, requires a pull request,
   and requires status checks to pass. Do not require an approving review — a
   solo developer cannot self-approve, and a rule that blocks every merge gets
   bypassed on day one.
3. **Decide the required checks** from the four jobs in `.github/workflows/ci.yml`:
   `scan_ruby` (brakeman + bundler-audit), `scan_js` (importmap audit), `lint`
   (rubocop), `test`. Default to all four — they already run on every PR, so
   requiring them costs nothing, and a check that runs but cannot block is
   decoration.
4. **Decide whether a local `PrePush` guard is still wanted** in `.overcommit.yml`.
   Server-side protection now catches the mistake, so a local hook only buys a
   1-second failure instead of a 30-second round trip — against the cost of
   another signed config and a hook that fresh clones lack until
   `overcommit --install` is run.
5. **Confirm the bypass list is empty**, including for the repo owner. The policy
   has no hotfix exception, so an owner bypass would quietly reintroduce one.

Verify by attempting a direct push to `main` and confirming it is refused.
