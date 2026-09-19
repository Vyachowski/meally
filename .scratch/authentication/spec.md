# Authentication

Status: needs-triage

Sign in with Google, on top of the stock Rails session. Nothing of this exists in
the codebase yet — there is no `User` and no `Session`, and
`rails g authentication` has not been run.

## Two layers that are easy to conflate

- **The Rails session** is where "this person is signed in" is stored.
  `rails g authentication` generates `User`, `Session`, `Current` and an
  `Authentication` concern: a signed cookie and session rotation.
- **Google OAuth** is only a way to prove who someone is. It ends in the same
  `start_new_session_for user` call as any other sign-in would.

OmniAuth does not replace the generator. It adds a second entry point into the
same session.

## Google only, no passwords

For stages 0–1 there is no password sign-in at all. That means deleting part of
what the generator produces: `PasswordsController`, the reset mailer with its
views, and the matching routes.

The gain is not just less code — with no passwords there is nothing to deliver by
email, nothing to store, and nothing to leak.

## Gems

| Gem | Version |
|---|---|
| `omniauth` | 2.1.4 |
| `omniauth-google-oauth2` | 1.2.3 |
| `omniauth-rails_csrf_protection` | 2.0.1 |

**The third is mandatory, not optional.** Without it the authorization path can
be reached by an unauthenticated GET request — the vulnerability class of
CVE-2015-9284.

## Google-side setup

Brand verification is **not** needed: the `email` and `profile` scopes are
non-sensitive. It becomes necessary only if we want our own name and logo on the
consent screen.

`GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are environment variables — set in
the Railway dashboard for production, in `.env` locally. Not in credentials; see
[ADR-0002](../../docs/adr/0002-secrets-as-environment-variables.md).

## Roles are deferred

No `admin:boolean`, no permission system. When it is needed — stage 2 — an enum
`role` column on `User`.

## Open questions

These block nothing today, but must not be lost.

- **There is no fallback sign-in.** Google-only means that losing access to the
  Google account means losing access to Meally. To be decided at stage 2, before
  the first paying user.
- **The redirect URI is `localhost:3000`.** Railway needs a real domain, which is
  still unchosen — the same open question that
  [`docs/deployment.md`](../../docs/deployment.md) records.
