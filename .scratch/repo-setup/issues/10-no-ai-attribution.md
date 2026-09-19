# No AI attribution in commits or pull requests

Type: task
Status: open
Map: ../map.md

## Question

Commits carry a `Co-Authored-By: Claude …` trailer and pull request bodies end
with `🤖 Generated with [Claude Code](…)`. Both stop, the rule is enforced
mechanically rather than written as prose, and the existing history is cleaned.

The tool that wrote a commit is not information anyone needs from `git log`, and
`git blame` already attributes the work to whoever committed it.

### Audit, 2026-09-19

- **21 commits on `main`** carry the trailer: 11 from the repo-setup work, 10
  predating it (back to `6a8aadf chore: remove kamal in favour of railway deploy`).
- **All 6 pull requests** (#17–#22) end with the generated-with line.
- No occurrences outside commit messages and pull request bodies.
- Stopped being added from `81c8169` onward.

## Part 1 — enforce it, do not merely document it

A rule that lives only in prose is re-broken by the next session that has a
different configuration. Three enforcement points, in descending order of value:

1. **Commit messages — a custom Overcommit `CommitMsg` hook.** The existing
   `MessageFormat` check inspects the subject line only, so a trailer in the body
   passes it. Overcommit supports custom hooks via a `plugin_directory` (default
   `.git-hooks`): add one that fails on `Co-Authored-By:` naming a tool, on
   `Generated with`, and on the 🤖 character. Remember `overcommit --sign` after
   editing `.overcommit.yml`, and that hooks are per clone.
2. **Pull request bodies — a CI check.** A template cannot enforce anything. A
   job that reads the PR body and fails on the same patterns can, because the
   ruleset from ticket 01 makes checks a merge gate. Note this adds a fifth
   required check, so the ruleset needs updating in the same change or merges
   will pass while the check is advisory.
3. **`.github/pull_request_template.md`** as the convention-carrying default, and
   a short line in `CONTRIBUTING.md` pointing at the enforcement rather than
   restating it.

Also track down **what was injecting the trailer** — harness or skill
configuration, not the repo — or a fresh session silently re-adds it and the
hook starts failing honest commits.

## Part 2 — rewrite the history

Decided: the 21 commits get cleaned, and `main` is force-pushed with lease. The
repo has a single owner, so the usual objection — rewriting history other people
have pulled — does not apply.

This is the destructive part. Sequence matters.

### Before touching anything

1. **Land or close every open pull request first.** Rewriting `main` orphans any
   branch based on the old SHAs. **PR #23 is open right now** and contains this
   very ticket.
2. **Take a backup ref**: `git branch backup/pre-rewrite main`, and note the
   current `main` SHA in this ticket before starting. It is the only way back.
3. **Note the other checkouts.** `git worktree list` shows the main checkout at
   `/Users/slava/Projects/meally` sitting at `22b429b` — already stale — plus the
   `repo-setup-map` worktree. Both need `git fetch && git reset --hard origin/main`
   afterwards, or they will try to push the old history back.

### The rewrite

`git-filter-repo` is **not installed** (`brew install git-filter-repo`). Options:

- **`git filter-repo --message-callback`** — the supported tool. It refuses to
  run on a repo with a remote unless `--force`, and it removes `origin` by
  design, so the remote has to be re-added afterwards.
- **`git rebase --root --exec`** — no new dependency, rewrites in place, and is
  easy to inspect step by step. Slower, and conflict-prone if any commit touches
  the same lines; with 31 commits it is manageable.
- **`git filter-branch --msg-filter`** — deprecated and warns loudly, but
  available with no install.

Whichever is used, the filter strips lines matching `Co-Authored-By:` for a tool
and the `🤖 Generated with` footer, leaving the rest of the message and the
trailing blank-line structure intact.

### The push

The ruleset from ticket 01 includes `non_fast_forward` with an **empty bypass
list**, so a force-push to `main` is refused — for the owner too. The rewrite
therefore requires:

1. Set the ruleset's `enforcement` to `disabled` (or add a temporary bypass
   actor) via `gh api`.
2. `git push --force-with-lease origin main`. Use `--force-with-lease`, not
   `--force`: it refuses if the remote moved since the last fetch.
3. **Set `enforcement` back to `active` immediately** and verify with a direct
   push attempt, exactly as ticket 01 did. Note ticket 01's caveat — a ruleset
   change takes a few seconds to take effect, so verify rather than assume.

Leaving the ruleset disabled is the realistic failure mode here. It is worth
writing the re-enable command down before running the disable command.

### Pull request bodies

Separate and non-destructive: `gh pr edit <n> --body …` for #17–#22, stripping
the footer. Six edits, no history implications, reversible.

## Definition of done

- A commit containing a tool `Co-Authored-By` trailer is rejected locally.
- A pull request whose body contains the footer cannot be merged.
- `git log --all --grep='Co-Authored-By: Claude'` returns nothing.
- PRs #17–#22 carry no generated-with footer.
- The ruleset is back to `enforcement: active` with an empty bypass list, and a
  direct push to `main` is refused.
- Both worktrees are reset onto the rewritten `main`.
