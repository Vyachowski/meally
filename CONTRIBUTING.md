# Contributing

These rules apply to everyone who commits here — the maintainer and coding
agents alike. Coding agents have a few extra rules in [`AGENTS.md`](AGENTS.md).

## First, install the git hooks

```sh
bundle install
bundle exec overcommit --install
```

Hooks live in `.git/hooks`, which is **per clone** — a fresh clone or a new git
worktree has none until you run that command. Without it, commit messages go
unchecked locally and are only caught later.

`.overcommit.yml` is signed. After editing it, run `bundle exec overcommit --sign`
or every hook refuses to run.

## Every change goes through a pull request

`main` is protected: a direct push is refused by GitHub, force-pushing and
deletion are blocked, and four CI checks must pass before a merge.

**There is no hotfix exception.** Urgent changes take the same path — the
carve-out is what erodes the policy, and this app has no paging users.

```sh
git switch -c feat/waist-entry main    # branch
# ... commit ...
git push -u origin feat/waist-entry
gh pr create --fill
gh pr merge <n> --rebase --delete-branch
```

No approving review is required — a solo maintainer cannot approve their own PR,
and a rule that blocks every merge gets bypassed on day one. CI is the gate.

## Branch names: `<type>/<slug>`

The type is one of the commit types below, so branches and commits share one
vocabulary:

```
feat/waist-entry
fix/solid-db-urls
docs/adr-secrets
chore/dependabot-sweep
```

When the work comes from a ticket in `.scratch/`, put its number after the type:
`docs/02-flow-doc-location`. Most branches have no ticket, so the number is not
mandatory — a scheme that is required but usually empty decays into `feat/00-…`.

## Commits: Conventional Commits, small and atomic

Enforced by `.overcommit.yml`, which rejects anything else at commit time:

```
<type>(<scope>)?(!)?: <subject>

type   build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test
scope  optional, lowercase
!      optional, marks a breaking change
```

Subject and body wrap at 72 characters, and the subject takes no trailing
period. `Merge`, `Revert`, `fixup!` and `squash!` are skipped.

```
feat(measurements): add waist entry form
```

Each commit should be one coherent change. This matters more here than in most
repos because of the merge rule below: **nothing is squashed, so every commit you
write lands on `main` exactly as written.**

## History stays linear: rebase only

Squash-merge and merge commits are both disabled on GitHub. A pull request can
only be rebased onto `main`, so `main` is a straight line and
`git log --oneline` stays readable.

The cost is real and deliberate: a branch full of `wip` and `fix the test`
commits cannot be tidied away at merge time. Clean it up first:

```sh
git rebase -i main
```

If this ever proves more expensive than it is worth, re-enabling squash-merge is
a one-line change — but do it as a decision, not as a workaround for one messy
branch.

## Branches are deleted after merging

Both sides, every time. The remote branch is deleted by GitHub automatically on
merge; `--delete-branch` on the merge command removes the local one.

Set these once per clone so stale branches and accidental merge commits cannot
accumulate:

```sh
git config fetch.prune true   # drop remote-tracking refs for deleted branches
git config pull.ff only       # a stale local main can never grow a merge commit
```

A branch checked out in a git worktree cannot be deleted. Switch that worktree
to another branch first, then delete.

## CI must be green

Four jobs run on every pull request, and all four are required to merge:

| Job | What it runs |
|---|---|
| `lint` | rubocop |
| `test` | `db:test:prepare test` against Postgres |
| `scan_ruby` | brakeman + bundler-audit |
| `scan_js` | importmap audit |

Run them locally before pushing:

```sh
bin/rubocop
bin/rails test
```

A pull request does **not** have to be rebased onto the latest `main` to merge.
That is a deliberate choice for a low-traffic repo; revisit it if concurrent
pull requests start landing on top of each other.
