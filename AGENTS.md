# AGENTS.md

Meally — a Ruby on Rails application.

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/` in this repo — there is no external tracker in use. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles are used verbatim: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`, recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and `docs/adr/` at the repo root (created lazily, not upfront). See `docs/agents/domain.md`.
