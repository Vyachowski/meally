# No AI attribution in commits or pull requests

Type: grilling
Status: open
Map: ../map.md

## Question

Commits carry a `Co-Authored-By: Claude …` trailer and pull request bodies end
with `🤖 Generated with [Claude Code](…)`. Both should stop.

The tool that wrote a commit is not information anyone needs from `git log`. It
is noise in a place that is expensive to clean and permanently in view — and
`git blame` already attributes the work to whoever actually committed it.

### Audit, 2026-09-19

- **21 commits on `main`** carry the trailer: 11 from the repo-setup work, 10
  predating it (back to `6a8aadf chore: remove kamal in favour of railway deploy`).
- **All 6 pull requests** (#17–#22) end with the generated-with line.
- No occurrences outside commit messages and pull request bodies.

### The part that cannot be undone

The trailers on `main` cannot be removed without rewriting 21 commits and
force-pushing, and the ruleset from ticket 01 blocks force-pushes to `main` by
design. Cleaning them would mean deliberately disabling the protection that was
just put in place, rewriting shared history, and turning it back on.

**Recommendation: leave the existing commits alone.** They are already public,
the cost of rewriting is real and the benefit is cosmetic. Draw the line at
today.

Pull request bodies are a different matter — `gh pr edit` changes them in place
with no history implications. Six edits, reversible, no downside.

## To resolve

1. **Decide the scope of the cleanup**: pull request bodies only (recommended),
   or also rewrite the 21 commits on `main`.
2. **Write the rule down.** It is an agent-behaviour rule, so `AGENTS.md` is the
   natural home, alongside the other agent-only addenda. Say it plainly: no
   `Co-Authored-By` trailers naming a tool, no generated-with footers in pull
   request bodies.
3. **Decide whether to enforce it mechanically.** Overcommit's `MessageFormat`
   only inspects the subject line, so a trailer in the body passes. Enforcing
   would need a custom `CommitMsg` hook that rejects the pattern. Weigh that
   against the fact that a written rule already covers the only party that was
   adding them, and a hook is another signed config and another per-clone
   install.
4. **Check the skills and harness configuration** for whatever was injecting the
   trailer, so the rule is not silently re-broken by a fresh session.

Point 4 matters most: the rule is worthless if the next session's configuration
re-adds the line automatically.
