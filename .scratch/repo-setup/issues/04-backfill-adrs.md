# Write the backfill ADRs

Type: task
Status: open
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

Use the format in the `domain-modeling` skill's `ADR-FORMAT.md`, numbered from
`0001`. Each ADR must survive being read alone, without the spec.

These record decisions already shipped, so each states its status as accepted and
is dated to when the decision was actually made, not to today.
