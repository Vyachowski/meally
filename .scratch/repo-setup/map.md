# Repo setup — developer flow and docs foundation

Label: wayfinder:map

## Destination

`main` is protected and every change reaches it through a branch and a PR, the
rules for that flow are written down in a tracked file, and the durable
decisions currently trapped in the untracked Russian `dev-docs/spec.md` live in
the repo as English docs — a rewritten README plus a small set of ADRs.

Reached when: a direct push to `main` is refused by GitHub, a new contributor
(human or agent) can read one tracked file and know how to land a change, and
`dev-docs/spec.md` holds nothing that anyone still needs.

## Notes

**Domain.** Meally — a Rails 8.1 app, single developer plus coding agents,
deployed to Railway. Minitest, importmap, Hotwire, ERB views, Postgres in Docker
locally. The application itself is still a bare skeleton: `app/` holds only the
four `Application*` base classes and three layouts, and everything in the log
before `a0212ff chore: delete all files` is gone. There is no CSS framework by
decision, and no Slim — both appear in the old history only.

**This map carries execution.** Unlike the wayfinder default, tickets here
produce commits, not just decisions — the destination *is* a change made in
place. A ticket is resolved when the change is merged, not when it is agreed.

**Skills to consult each session:** `grilling` and `domain-modeling` for the
decision tickets; `writing-for-agents` when editing AGENTS.md or any file
agents read.

**Standing preferences for this effort** — settled while charting, 2026-09-19:

- **Tracked docs are English.** The spec is Russian; commits, `docs/agents/`
  and everything tracked from here are English. Russian stays fine for scratch.
- **Conventional Commits**, already enforced by `.overcommit.yml`
  (`MessageFormat`, 72-char subject and body). Nothing to decide, only to document.
- **Linear history, rebase-only.** No squash-merge, no merge commits. Forces
  small atomic commits; a noisy agent branch gets an interactive rebase before
  it can land. Squash can be re-enabled later if the discipline proves too costly.
- **Branch naming: `<type>/<slug>`** mirroring the commit types —
  `feat/waist-entry`, `fix/solid-db-urls`, `docs/adr-secrets`,
  `chore/dependabot-sweep`. A ticket number is appended only when the work comes
  from a `.scratch` ticket (`docs/02-flow-doc-location`).
- **Branches are deleted on both sides after every merge.** Remote: GitHub's
  `deleteBranchOnMerge`. Local: `fetch.prune = true` plus the canonical merge
  command `gh pr merge <n> --rebase --delete-branch`. `pull.ff = only` is set so
  a stale local `main` cannot grow a merge commit.
- **`.scratch/` is tracked**, settled by landing the map on `main`: the tracker
  is shared history that a future reader can follow, not private scratch.
  `dev-docs/` and `.claude/worktrees/` stay ignored.
- **No AI attribution.** No `Co-Authored-By` trailer naming a tool, no
  generated-with footer in a pull request body. In effect from 2026-09-19, to be
  enforced mechanically rather than by prose, and the 21 commits already on
  `main` get rewritten and force-pushed with lease. See ticket 10.
- **No hotfix exception.** Every change goes through a branch and a PR,
  including urgent ones. The carve-out is what erodes the policy, and this app
  has no paging users.

**Already done while charting:**

- **The repo is public** (`Vyachowski/meally`, 2026-09-19). Branch protection
  and rulesets are unavailable on private repos on the Free plan — the API
  returned 403 "Upgrade to GitHub Pro or make this repository public". Going
  public was chosen over $4/mo while the project earns nothing; it flips back to
  private if that changes. History was scanned first: `master.key` and `.env`
  were never committed, `credentials.yml.enc` is ciphertext whose key never
  entered the repo, and the only secret-shaped strings are the ephemeral
  `postgres:postgres` CI service credentials and Rails boilerplate comments.

## Decisions so far

<!-- one line per resolved ticket: gist + link -->

- [Lock down `main`](issues/01-lock-down-main.md) — `main` refuses direct pushes:
  rebase-only merges, a ruleset requiring a PR plus all four CI checks, empty
  bypass list. No local `PrePush` hook (one server-side enforcement point beats
  two), and `strict_required_status_checks_policy` left off until parallel agent
  PRs make it worth the rebase tax.
- [Where the developer-flow rules live](issues/02-flow-doc-location.md) —
  `CONTRIBUTING.md` is the single source of truth for the shared rules;
  `AGENTS.md` carries only agent-only addenda plus an instruction to read it.
- [Sort `dev-docs/spec.md` into its destinations](issues/03-sort-the-spec.md) —
  four ADRs (Railway, secrets, Solid database URLs, no CSS framework), the
  operational material to `docs/deployment.md`, the auth plan to a feature spec,
  sections 5 and 8 discarded, and `dev-docs/` retired outright in ticket 07.
- [Write the backfill ADRs](issues/04-backfill-adrs.md) — `docs/adr/0001`–`0004`
  cover Railway, secrets as environment variables, the derived Solid database
  URLs, and the absent CSS framework, each dated to when it was decided.
- [Rewrite the README and write `docs/deployment.md`](issues/05-rewrite-readme.md)
  — the README carries local setup only, the deployment doc takes the Railway
  variables, the `PORT=80` Thruster explanation and the environment model, and
  `CONTRIBUTING.md` gains the testing conventions.
- [Move the authentication plan to a feature spec](issues/08-authentication-spec.md)
  — `.scratch/authentication/spec.md`, with the mandatory CSRF-protection gem and
  both open questions preserved as open.
- [Dependabot policy and the open PR backlog](issues/06-dependabot-policy.md) —
  minor and patch grouped weekly and auto-merged behind the required checks,
  majors read by hand; `image_processing` deleted rather than bumped.

## Not yet specified

- **Whether `docs/agents/*.md` needs revising** once the flow doc exists — the
  three scaffolded files describe conventions that the flow doc may restate or
  contradict.
- **CI required-checks drift.** The `system-test` job is commented out in
  `ci.yml` and returns with the first system test; whatever ruleset ticket 01
  writes will need updating then.
- **Onboarding beyond the README** — `.env.example` completeness, `bin/setup`,
  whether `mise`/`.ruby-version` needs documenting. Sharpens once the README
  rewrite in ticket 05 exposes what is actually missing.

## Out of scope

- **`CONTEXT.md` and the domain glossary.** `dev-docs/spec.md` §5 says the
  domain model is explicitly undecided, and `docs/agents/domain.md` says
  CONTEXT.md is created lazily when terms resolve. Writing one now produces a
  file that lies.
- **The agent working-agreement map** — how agents pick up `.scratch` tickets,
  when they open PRs, worktree conventions, triage labels in practice. A
  separate effort that depends on this one being settled first.
- **Staging environment / Railway environments.** `dev-docs/spec.md` §2 defers a
  staging stand to "stage 1, friends"; the only user today is the author.
