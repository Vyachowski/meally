# Write the backfill ADRs

Type: task
Status: resolved
Blocked by: 03
Map: ../map.md

## Question

Create `docs/adr/` and write, in English, the ADRs that ticket 03 assigns. The
charting round settled the depth: backfill only the decisions that were expensive
to learn and that a future reader would otherwise undo. The leading candidates:

- **Secrets as environment variables, not Rails credentials.** A real trade-off
  with a cost attached — the standing obligation to keep a copy in a password
  manager, since the values live only in the Railway dashboard.
- **Deriving the Solid Cache/Queue/Cable database URLs from `DATABASE_URL`.** The
  one that cost a silent production failure: `DATABASE_URL` applies only to the
  primary database, the three Solid databases silently kept their localhost
  defaults, and an explicit `database:` key does not override the name from
  `url:`. All of that is empirically established and none of it is guessable.
- **Railway over Kamal/VPS.** Cheap to state, and it explains why nine gems and
  `config/deploy.yml` disappeared from the history.
- **No CSS framework.** Added by ticket 03 as a fourth backfill. Four
  alternatives were named and rejected with specific reasons — Tailwind + daisyUI
  ("technical debt at the start"), Web Awesome, Bootstrap's 226 KB CSS plus 78 KB
  JS, and Pico CSS's dead maintainer — which is exactly the research a future
  reader would otherwise repeat. The ~800-line retreat threshold and "keep logic
  out of views" become its consequences.

Use the format in the `domain-modeling` skill's `ADR-FORMAT.md`, numbered from
`0001`. Each ADR must survive being read alone, without the spec.

These record decisions already shipped, so each states its status as accepted and
is dated to when the decision was actually made, not to today.

## Answer

Resolved 2026-09-19. Four ADRs written in `docs/adr/`, each dated to when the
decision was actually taken rather than to today, and each readable without the
spec:

| ADR | Decision | Dated |
|---|---|---|
| [0001](../../../docs/adr/0001-deploy-to-railway.md) | Deploy to Railway | 2026-09-06 |
| [0002](../../../docs/adr/0002-secrets-as-environment-variables.md) | Secrets in environment variables, not credentials | 2026-09-06 |
| [0003](../../../docs/adr/0003-derive-solid-database-urls.md) | Derive the Solid database URLs from `DATABASE_URL` | 2026-09-07 |
| [0004](../../../docs/adr/0004-no-css-framework.md) | No CSS framework | 2026-09-06 |

Dates come from the commits that carried each decision — `6a8aadf` for Railway
and the Kamal removal, `23d5b2f` for the Solid URLs — and from the spec's own
draft date for the two that left no single commit.

Each keeps only the optional sections that earn their place, per the format:

- **0002** carries Consequences because of the standing obligation it creates —
  production secrets exist only in the Railway dashboard, so a copy must be kept
  in a password manager.
- **0003** carries Consequences because its failure mode is silent: a green
  deploy that dies at the first cache write or enqueued job, not at boot. It also
  records all three empirical findings, since each one rules out a
  simplification a future reader would otherwise attempt.
- **0004** carries Considered Options, which is the whole reason it exists — four
  alternatives rejected for specific reasons that would otherwise be
  re-researched.

No index file was added to `docs/adr/`. Four files sorted by number need no
table of contents, and an index is another thing to forget to update.
