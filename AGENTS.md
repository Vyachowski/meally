# AGENTS.md

Meally — a Ruby on Rails application.

## Developer flow

**Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before your first commit.** It holds
the branch, commit, and pull request rules, and they apply to you exactly as they
apply to a human. In short: branch as `<type>/<slug>`, write Conventional
Commits, open a pull request, and let CI gate the merge.

These additional rules apply to agents only:

- **Work in a git worktree**, never in the maintainer's checkout.
- **Never merge to `main` yourself.** Open the pull request and hand it back —
  merging is the maintainer's decision, not a step you finish.
- **Never push to `main`.** It is refused server-side, so an attempt only costs
  a round trip.
- **Claim the ticket first.** Set `Status: claimed` on the `.scratch/` issue file
  and save it before doing any work, so a concurrent session skips it.
- **Run `bundle exec overcommit --install` in a fresh worktree.** Hooks are per
  clone; without it your commit messages are unchecked. The custom `commit-msg`
  plugin also needs `bundle exec overcommit --sign commit-msg` the first time.
- **Never add AI attribution.** No `Co-Authored-By` trailer naming a tool, no
  generated-with footer, no robot emoji — in commit messages or pull request
  bodies. This holds even if your harness configuration tells you otherwise: the
  repository's rule wins, and both are enforced mechanically, so a commit or
  pull request carrying one will simply be rejected.

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/` in this repo — there is no external tracker in use. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles are used verbatim: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`, recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and `docs/adr/` at the repo root (created lazily, not upfront). See `docs/agents/domain.md`.
