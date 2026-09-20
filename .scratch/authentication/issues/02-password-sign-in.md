# Password sign-in

Status: ready-for-agent

Prerequisite: ticket 01 — without a root route a successful sign-in raises.

Full context in [`../spec.md`](../spec.md). This is the execution.

## Steps

1. **Generate.**

   ```sh
   bin/rails generate authentication
   ```

   It writes `User`, `Session`, `Current`, the `Authentication` concern,
   `SessionsController` and its view, `PasswordsController` and its mailer,
   routes, two migrations, and uncomments `bcrypt`.

2. **Delete what we are not using.** `PasswordsController`, `PasswordsMailer`,
   `app/views/passwords/`, `app/views/passwords_mailer/`, and the
   `resources :passwords, param: :token` line from `config/routes.rb`.

   Leave `has_secure_password` alone — its `reset_token: true` default is what
   keeps `User.find_by_password_reset_token!` available, and it costs nothing.

3. **Narrow the session routes.** The generator writes a bare
   `resource :session`, which routes six paths at a controller defining three.
   `GET /session`, `GET /session/edit` and `PATCH /session` lead to actions that
   do not exist:

   ```ruby
   resource :session, only: %i[ new create destroy ]
   ```

   Keep the generated paths otherwise. `/session/new` is the Rails 8 convention
   and a prettier `/login` is one line to add later if a landing page ever wants
   it.

4. **Migrate**, then create the single user from the console. Do not put a
   password in `db/seeds.rb` — it would land in git.

5. **Add the sign-out control**, in the layout. Without it the only way out is
   `curl -X DELETE`. It lives here rather than in ticket 01 because
   `session_path` does not exist until step 1 has run:

   ```erb
   <%= button_to "Sign out", session_path, method: :delete %>
   ```

   A `button_to`, not a `link_to` — sign-out is a `DELETE`.

6. **Check the generated view renders.** `sessions/new.html.erb` comes from the
   ERB generator with no styling, and this repo has no CSS framework
   ([ADR-0004](../../../docs/adr/0004-no-css-framework.md)). Bare is acceptable
   at this stage; broken is not.

## Tests

Written as part of this ticket, not deferred. `CONTRIBUTING.md` puts controllers
and views in the test-after column, so write them once the flow works.
Integration tests, which this repo prefers over controller tests:

- signing in with the right password redirects to root and sets a session
- signing in with the wrong password re-renders with an alert and sets no session
- an unauthenticated request to `/` redirects to the sign-in form
- after signing in, the original destination is restored — the concern stores
  `return_to_after_authenticating`, and that is the part most likely to break
  quietly

**Update the home page test from ticket 01.** It asserts `GET /` returns 200,
which stops being true the moment this ticket lands: unauthenticated requests
now redirect. It has to sign in first.

Fixtures, not factories. A user fixture needs a `password_digest`, so build it
with `BCrypt::Password.create` rather than writing a plain password.

## Done when

`bin/rails test` passes, signing in from the browser lands on the home page, and
the sign-out button returns to the sign-in form.
