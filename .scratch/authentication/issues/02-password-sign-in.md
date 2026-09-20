# 02 — Password sign-in

**What to build:** the single user can sign in with an email address and a
password, reach the home page, and sign out again. Everything else in the
application requires a session.

Rails generates all of it. The work is running the generator, deleting the parts
this project does not use, and proving the flow with tests.

**Password reset is deleted**, not kept: it needs mail delivery this app has not
got, and removing the controller does not remove the underlying capability. **No
registration** is built — the generator does not produce one, and there is one
user, created by hand. Both decisions, and what the deleted flow did, are in
[`../spec.md`](../spec.md).

The generator also routes more session paths than its controller answers; narrow
them to what exists. Keep the generated path names — a prettier `/login` is a
one-line alias later if a landing page ever wants it.

A sign-out control belongs here rather than in 01, because the route it needs
does not exist until the generator has run. Without it the only way out is a
hand-made `DELETE`.

**Blocked by:** 01 — a successful sign-in redirects to root, which must exist.

**Status:** ready-for-agent

- [ ] Signing in with the correct password reaches the home page
- [ ] Signing in with a wrong password reports it and starts no session
- [ ] An unauthenticated request to any page lands on the sign-in form
- [ ] After signing in, the originally requested page is restored — not the home
      page
- [ ] A sign-out control ends the session and returns to the sign-in form
- [ ] No route resolves to an action that does not exist
- [ ] Nothing that needs mail delivery remains
- [ ] No password appears in the repository, including seeds and fixtures
- [ ] The home page test from 01 is updated — it now signs in first
- [ ] `bin/rubocop` is clean and CI is green
