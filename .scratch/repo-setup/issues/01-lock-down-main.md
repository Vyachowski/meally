# Lock down `main`

Type: task
Status: resolved
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

## Answer

Done, 2026-09-19. `main` now refuses direct pushes.

### Merge settings

`mergeCommitAllowed: false`, `squashMergeAllowed: false`,
`rebaseMergeAllowed: true`, `deleteBranchOnMerge: true`. Rebase is the only way
to land a PR, so `main` cannot go non-linear.

### Ruleset

Repository ruleset **`main`**, id `23696902`, `enforcement: active`,
`bypass_actors: []` (`current_user_can_bypass: never` — the owner included).
Condition: `~DEFAULT_BRANCH`. Rules:

| Rule | Effect |
|---|---|
| `pull_request` | 0 required approvals, `allowed_merge_methods: ["rebase"]` |
| `required_status_checks` | `lint`, `test`, `scan_ruby`, `scan_js` |
| `required_linear_history` | no merge commits can reach `main` |
| `non_fast_forward` | no force-push |
| `deletion` | `main` cannot be deleted |

### Decisions made inside this ticket

- **All four checks are required** (item 3, as recommended). They already run on
  every PR; requiring them turns them from advisory into a gate.
- **`strict_required_status_checks_policy: false`** — a PR does not have to be
  rebased onto the latest `main` before merging. Strict mode guards against
  semantic conflicts between concurrent PRs, which a single developer rarely
  produces, and its cost is rebasing every open PR each time `main` moves — six
  stale dependabot PRs would each need it. **Revisit when parallel agent PRs
  become routine**, which is the case where strict mode earns its keep.
- **No local `PrePush` guard** (item 4). The server-side rule already refuses the
  push with a clear `GH013` error, so a hook would only make the same failure
  arrive faster — while adding a second place the policy is written, a re-signed
  `.overcommit.yml`, and a guard that silently does not exist in any clone where
  `overcommit --install` has not been run. One enforcement point, server-side, is
  the one that cannot be skipped.
- **Branch deletion is automatic on both sides.** Remote: `deleteBranchOnMerge`
  (verified — `docs/repo-setup-map` vanished on merge without being asked).
  Local: `fetch.prune = true` in the repo config clears stale remote-tracking
  refs on every fetch, and the canonical merge command
  `gh pr merge <n> --rebase --delete-branch` removes the local branch. Also set
  `pull.ff = only`, so a stale local `main` can never grow a merge commit.

### Verification

A direct push to `main` was rejected:

```
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: - Changes must be made through a pull request.
remote: - 4 of 4 required status checks are expected.
! [remote rejected] HEAD -> main (push declined due to repository rule violations)
```

**Caveat worth knowing: a newly created ruleset takes a few seconds to take
effect.** The first verification push, issued immediately after the `POST`, was
*accepted* — it carried the map commit onto `main` and GitHub consequently marked
PR #17 as merged. The retest moments later was correctly refused. So a ruleset
that appears active in the API is not necessarily enforcing yet; when creating
one, wait and verify rather than trusting the response.
