# Move the authentication plan to a feature spec

Type: task
Status: resolved
Blocked by: 03
Map: ../map.md

## Question

Section 4 of `dev-docs/spec.md` plans authentication for work that has not
started — there is no `User` and no `Session` in `app/` today. Ticket 03 routes
it to `.scratch/authentication/spec.md`, the repo's own convention for a feature
spec per `docs/agents/issue-tracker.md`.

Translate it into English and write it there. What it carries:

- **Google OAuth over the stock Rails session.** Two layers that are easy to
  conflate: `rails g authentication` provides `User`, `Session`, `Current` and
  the `Authentication` concern — the storage of "this person is logged in" —
  while Google OAuth is only a way to prove identity, ending in the same
  `start_new_session_for user` call as any other sign-in. OmniAuth adds a second
  entry point to the same session rather than replacing the generator.
- **Google-only, no passwords** for stages 0–1, so `PasswordsController`, the
  reset mailer and its views and routes all get deleted from what the generator
  produces. Nothing to deliver by email, nothing to store, nothing to leak.
- **The three gems**, pinned: `omniauth` 2.1.4, `omniauth-google-oauth2` 1.2.3,
  `omniauth-rails_csrf_protection` 2.0.1. The third is **mandatory** — without it
  the authorization path is reachable by an unauthenticated GET request, the
  vulnerability class of CVE-2015-9284.
- **No Google brand verification needed**: the `email` and `profile` scopes are
  non-sensitive. It becomes necessary only to put our own name and logo on the
  consent screen.
- **Roles deferred** — no `admin:boolean`, no permission system. When needed at
  stage 2, an enum `role` column on `User`.

Two open items travel with it and must not be silently dropped:

- **No fallback sign-in.** Google-only means losing the Google account means
  losing Meally. To be decided at stage 2, before the first paying user.
- **Redirect URI** is `localhost:3000` today; Railway needs a real domain, which
  is still unchosen.

This is a spec for future work, not a decision record — do not write it as an
ADR.

## Answer

Resolved 2026-09-19. Written to `.scratch/authentication/spec.md`, in English,
carrying `Status: needs-triage` per the repo's triage convention.

Everything from spec section 4 survives: the two-layers distinction between the
Rails session and Google OAuth, Google-only with the generator's password
machinery deleted, the three pinned gems with `omniauth-rails_csrf_protection`
marked mandatory rather than optional, the non-sensitive scopes point about brand
verification, and deferred roles.

Both open questions are kept as open questions rather than being quietly
resolved: no fallback sign-in, and a redirect URI that depends on the unchosen
domain. The second is cross-linked to `docs/deployment.md`, which records the
same open item from the deployment side, so neither can be closed without the
other being noticed.

The secrets point links to ADR-0002 instead of restating the reasoning.
