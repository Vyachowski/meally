# Sort `dev-docs/spec.md` into its destinations

Type: grilling
Status: resolved
Blocked by: 02
Map: ../map.md

## Question

`dev-docs/spec.md` is 336 untracked Russian lines across eight sections. It was
settled while charting that it gets split rather than moved wholesale: durable
trade-offs become ADRs, operational how-to becomes README or `docs/` prose, and
the rest is discarded. It was also settled that only the expensive decisions get
backfilled as ADRs, not all six candidates.

What is not settled is the sort itself. Go section by section and assign each a
destination — ADR, README, a `docs/` page, or discard:

1. Deploy — Railway (incl. secrets-as-env-vars, Railway variables, the port
   decision, the Solid Cache/Queue/Cable database URLs)
2. Environments (`RAILS_ENV` vs Railway environment; no separate test stand)
3. Local environment (services in Docker, app on the host)
4. Authentication (Google OAuth over Rails sessions) — note this describes work
   not yet done, which may make it a spec rather than a decision record
5. Domain model — explicitly undecided; ruled out of scope for this map
6. Frontend and CSS (no framework, Pico CSS, quality bar per stage)
7. Tests (Minitest, fixtures over FactoryBot, test-first for calculations)
8. CI — GitHub Actions (pinned Postgres image, the removed `system-test` job)

Sections 4 and 6 are the awkward ones: they record intentions about future work
rather than decisions already made, and an ADR for an unimplemented decision ages
badly.

Output: a table mapping each section to its destination, with whatever is
discarded named explicitly so it is a choice and not an oversight. Feeds tickets
04 and 05, and settles the fate of `dev-docs/` itself.

Blocked by 02 because "README or a `docs/` page" cannot be answered before the
doc layout is decided.

## Answer

Resolved 2026-09-19.

### Two findings that shaped the sort

**The app is a bare Rails skeleton.** `app/` holds only `ApplicationRecord`,
`ApplicationController`, `ApplicationMailer`, `ApplicationJob` and three ERB
layouts. There is no `User` and no `Session`, so `rails g authentication` has not
been run in the current codebase — the measurements, profile and auth work in the
log all predates `a0212ff chore: delete all files`. That makes sections 4, 5 and
6 descriptions of work not yet started, not records of decisions taken.

**Neither Slim nor Pico CSS is present**, despite both appearing in the old
history. The Gemfile has no `slim`, every view is `.erb`, and section 6 of the
spec explicitly *rejects* Pico (no release in 18 months, maintainer disappeared).
The map's Notes claimed otherwise and have been corrected.

### The sort

| § | Content | Destination |
|---|---|---|
| 1 | Railway over Kamal/VPS | ADR-0001 |
| 1 | Secrets as environment variables, not credentials | ADR-0002 |
| 1 | Solid Cache/Queue/Cable URLs derived from `DATABASE_URL` | ADR-0003 |
| 1 | Railway variables table, `PORT=80` / Thruster | `docs/deployment.md` |
| 2 | `RAILS_ENV` vs Railway environment; no staging yet | `docs/deployment.md` |
| 3 | Docker for services, app on the host | README, with a short why |
| 4 | Google OAuth plan, gems, CVE note, open items | `.scratch/02-authentication/spec.md` |
| 5 | Domain model — undecided | discard |
| 6 | No CSS framework, four alternatives rejected | ADR-0004 |
| 7 | Minitest, fixtures over FactoryBot, test-first | `CONTRIBUTING.md` + README |
| 8 | CI: pinned `postgres:18`, removed system-test job | discard |

### Why each of the non-obvious ones

- **Operational Railway material gets `docs/deployment.md`**, not the README. A
  variables table and a Thruster port explanation are what you consult when
  something breaks; the README should stay short enough to be read end to end.
  Its job is "run this locally", with deployment one link away.
- **Authentication goes to `.scratch/02-authentication/spec.md`**, the repo's own
  convention for a feature spec per `docs/agents/issue-tracker.md`. It is not a
  decision record — nothing was decided by building it — and not documentation,
  since there is nothing yet to document. It is the next feature's spec, and it
  belongs where the tracker expects work to start from.
- **Frontend becomes ADR-0004**, a fourth backfill beyond the three agreed while
  charting. It is the most ADR-shaped section in the file: four alternatives
  named and rejected with specific reasons (Tailwind + daisyUI as "technical debt
  at the start", Web Awesome on the same markup argument, Bootstrap's 226 KB CSS
  plus 78 KB JS, Pico's dead maintainer), and "why is there no CSS framework in a
  2026 Rails app" is a question that will be asked. The ~800-line retreat
  threshold and "keep logic out of views" become its consequences.
- **Section 8 is discarded** because it is already recorded where it matters:
  `ci.yml` carries the pinned image and the commented-out system-test block with
  its reasoning, and `CONTRIBUTING.md` now lists the four required checks.
  Restating it in a doc creates a second copy to drift.

### `dev-docs/` is retired, not kept

Delete the directory outright and drop its `/dev-docs/` rule from `.gitignore`,
rather than keeping it as a scratchpad. **Sequenced into ticket 07**, blocked by
04 and 05: the file is untracked and ignored, so deleting it before those tickets
have drained it would destroy the source with nothing to recover from. A backup
lives outside the repo until then.
