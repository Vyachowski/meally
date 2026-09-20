# Authentication

Status: ready-for-agent

Email and password sign-in, straight from the Rails generator, with everything we
do not need deleted.

Nothing exists yet: `app/` holds only the four `Application*` base classes,
`db/migrate/` is empty, the schema is at `version: 0`, and `bcrypt` is
commented out in the Gemfile.

## What we build

`bin/rails generate authentication` produces all of it:

- models `User`, `Session`, `Current`
- the `Authentication` concern, included into `ApplicationController`
- `SessionsController` and its `new` view
- routes `resource :session` and `resources :passwords`
- migrations for `users` (`email_address`, `password_digest`) and `sessions`
  (`user` reference, `ip_address`, `user_agent`)
- uncomments `bcrypt` in the Gemfile and bundles

Then delete the parts we are not using, below.

## What the generator gives for free

Worth knowing so nobody reimplements it:

- `rate_limit to: 10, within: 3.minutes` on session creation
- `User.authenticate_by`, which resists timing-based account enumeration
- `normalizes :email_address` — strips and downcases
- sessions record `ip_address` and `user_agent`
- `has_many :sessions, dependent: :destroy`, so deleting a user ends their sessions

## What we delete, and why

### Registration — nothing to delete, nothing to write

The generator does not create it. There is no `UsersController` and no sign-up
view; only `resource :session` and `resources :passwords` are routed.

One user, created by hand. A sign-up form is code to validate, spam-protect and
later remove, and it arrives with the first invited person — at which point it
will also be clear whether it is open or invite-only. Too early to decide now.

### Password reset — delete it

Remove `PasswordsController`, `PasswordsMailer`, its two views, and the
`resources :passwords` route.

It cannot work here. No SMTP provider is configured and
`config.action_mailer.default_url_options` is still `host: "example.com"`, so
`create` would enqueue a job that fails and the link in the mail would point
nowhere.

**Deleting the controller does not remove the capability.**
`has_secure_password` takes `reset_token: true` by default, so
`user.password_reset_token` and `User.find_by_password_reset_token!` remain on
the model either way. Recovery at this stage is one console line:

```ruby
User.first.update!(password: "…")
```

Worth knowing what the deleted flow did, for when it comes back: it answered
identically whether or not the address existed (enumeration protection), rate
limited at 10 per 3 minutes, and destroyed every session of the user on
successful reset. The file is in git history — restoring is cheaper than
rewriting.

### Google OAuth — dropped, not deferred

Removed 2026-09-20. It was blocked regardless: the production redirect URI needs
a domain, and the domain is undecided — see [ADR-0001](../../docs/adr/0001-deploy-to-railway.md)
and [`docs/deployment.md`](../../docs/deployment.md).

Planning it now is clutter. If it returns, the earlier plan is in git history:
three pinned gems, the non-sensitive `email` and `profile` scopes meaning no
brand verification is needed, and the note that `omniauth-rails_csrf_protection`
is **mandatory** — without it the authorization path is reachable by an
unauthenticated GET, the CVE-2015-9284 class.

The shape it would take is unchanged and worth one line: OmniAuth does not
replace the generator, it adds a second entry point into the same session,
ending in the same `start_new_session_for`.

## What the URLs end up being

The generator routes a *singular* `resource :session` — the resource is "my
current session", so signing in creates one and signing out deletes it. There is
no `/login` and no `GET /logout`.

| Path | Behind authentication? | What |
|---|---|---|
| `GET /` | yes | `home#index` |
| `GET /session/new` | no | the sign-in form |
| `POST /session` | no | sign in |
| `DELETE /session` | yes | sign out |
| `GET /up` | no | health check |

Two public paths, and that is the whole of it. The mechanism is the reverse of
what it looks like: the `Authentication` concern is included into
`ApplicationController` and closes *everything*, then `SessionsController` opens
itself back up with `allow_unauthenticated_access only: %i[new create]`.

`/up` is unaffected because `Rails::HealthController` inherits from
`ActionController::Base`, not from `ApplicationController` — checked, not
assumed. Railway's health checks keep working once the app goes behind a login.

Hitting `/` while signed out stores `/` in the session, redirects to
`/session/new`, and returns there after a successful sign-in.

## Prerequisite: a root route must exist

`after_authentication_url` falls back to `root_url`, and `config/routes.rb` has
root commented out (`# root "posts#index"`). **A successful login would raise
`ActionController::UrlGenerationError`.**

So a home page has to exist before sign-in works end to end. What goes on it is a
product decision, not part of this spec — but authentication cannot be verified
without it.

## Open

- **How the first user is created.** Console or `db/seeds.rb`. A seed must not
  carry a password into git; if seeds are used it has to come from an
  environment variable. Recommend the console at this stage — one user, once,
  and nothing to leak.

## Known cost

If passwords are still here when other people arrive, password reset becomes
mandatory the first time someone forgets one — and that means an SMTP provider,
a real domain and `default_url_options`. This decision defers that bill, it does
not cancel it.
