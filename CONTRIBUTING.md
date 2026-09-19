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
deletion are blocked, and five CI checks must pass before a merge.

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

### No AI attribution

No `Co-Authored-By` trailer naming a tool, no generated-with footer, no robot
emoji — in commit messages or pull request bodies. Which tool typed a change is
not something anyone needs from `git log`, and `git blame` already records who
committed it.

This is enforced, not merely requested: a custom `commit-msg` hook in
`.git-hooks/` rejects the commit, and the `pr_body` check does the same for pull
request bodies. Because the hook is a custom plugin, Overcommit asks you to
verify and sign it the first time:

```sh
bundle exec overcommit --sign commit-msg
```

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

## Tests

Minitest, which comes with Rails. Nothing is added to it.

**Model and integration tests are the base.** An integration test walks the whole
route → controller → HTML chain and still runs fast, which makes it the default
choice. **Controller tests are not written** — Rails recommends integration tests
in their place.

**System tests (Capybara + Selenium) only where a real browser is genuinely
required**, such as Turbo Stream behaviour. Expect a handful across the whole
project, not a suite. There is no `system-test` job in CI yet; it returns
alongside the first system test.

**Fixtures, not FactoryBot.** They are already wired up (`fixtures :all`), they
are Rails-native, and they load once inside a transaction. The known cost is
real: as associations grow, the data spreads across YAML files and it stops being
obvious where a record in a given test came from. Add a factory gem when that
actually hurts, not in anticipation.

**Test-first for models and calculations** — pure functions are naturally
described by examples before they exist. **Test-after for controllers and views**,
where the shape only settles once you see it.

Tests run in parallel across your cores, each worker with its own database
(`meally_test-0`, `meally_test-1`, …), so Postgres must be running.

## CI must be green

GitHub Actions is the gate. Five checks run on every pull request and all five
are required to merge:

| Check | What it runs |
|---|---|
| `lint` | rubocop |
| `test` | `db:test:prepare test` against Postgres |
| `scan_ruby` | brakeman + bundler-audit |
| `scan_js` | importmap audit |
| `pr_body` | rejects AI attribution in the pull request body |

Locally, before pushing:

```sh
docker compose up -d    # Postgres must be running first
bin/rubocop
bin/rails test
```

`docker compose` needs `DB_PASSWORD` set in `.env`; see `.env.example`.

### `bin/ci` is not used

Rails 8.1 also generates `bin/ci` and `config/ci.rb` — a local runner with its
own list of steps. **Nothing here calls it**: no workflow, no hook. Its list is
maintained separately from the workflow's and the two can disagree, so a green
`bin/ci` promises nothing about a pull request.

Treat it as unused until we decide to wire it up.

A pull request does **not** have to be rebased onto the latest `main` to merge.
That is a deliberate choice for a low-traffic repo; revisit it if concurrent
pull requests start landing on top of each other.
