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
   `resources :passwords, param: :token` line from `config/routes.rb`. Leave
   `resource :session`.

   Leave `has_secure_password` alone — its `reset_token: true` default is what
   keeps `User.find_by_password_reset_token!` available, and it costs nothing.

3. **Migrate**, then create the single user from the console. Do not put a
   password in `db/seeds.rb` — it would land in git.

4. **Check the generated view renders.** `sessions/new.html.erb` comes from the
   ERB generator and has no styling; the repo has no CSS framework
   ([ADR-0004](../../../docs/adr/0004-no-css-framework.md)), so it will look
   bare. Bare is acceptable at this stage; broken is not.

## Tests

Written as part of this ticket, not deferred. `CONTRIBUTING.md` puts controllers
and views in the test-after column, so write them once the flow works.

Integration tests, which is what the repo prefers over controller tests:

- signing in with the right password redirects to root and sets a session
- signing in with the wrong password re-renders with an alert and sets no session
- an unauthenticated request to root redirects to the sign-in page
- after signing in, the original destination is restored — the concern stores
  `return_to_after_authenticating`, and that is the part most likely to break
  quietly

Fixtures, not factories. A user fixture needs a `password_digest`, so generate
it with `BCrypt::Password.create` rather than writing a plain password.

## Done when

`bin/rails test` passes, signing in from the browser lands on the home page, and
signing out returns to the sign-in form.
