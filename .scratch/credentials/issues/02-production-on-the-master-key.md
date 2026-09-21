# 02 — Production runs on the master key

**What to build:** the deployed application boots from an encrypted credentials
file unlocked by a master key, instead of from a secret pasted into the
platform's variables. Signing in on production keeps working across the switch,
and anyone already signed in stays signed in.

That last part is the whole risk in this ticket. Session cookies are signed with
the secret, so the value written into credentials has to be the value production
is using right now. A freshly generated one deploys green and silently signs
everybody out.

The deployment doc lists the variables that should exist; after this ticket it
has to match what the dashboard actually holds, including the one that is now
gone.

**Blocked by:** 01 — the decision has to be recorded before production follows
it.

**Status:** ready-for-human — the values are set by hand in the Railway
dashboard and the key is never pasted into an agent session. Everything else in
the ticket is ordinary work.

- [x] The deployed application serves requests with no secret key variable set
      on the platform
- [x] A session that was live before the switch is still live after it
- [x] Signing in and signing out both still work on production
- [x] A deploy from a clean checkout succeeds, and the health check answers
- [x] The deployment doc's variable table matches the dashboard exactly —
      no variable listed that is not set, none set that is not listed
- [x] The master key is in the password manager before it is needed anywhere

Context: [`../spec.md`](../spec.md) — see "Details that bite" for why the
existing secret value has to be reused, and why the image build needs no key.

Delivered by pull request #45, merged 2026-09-21. Production boots from the
encrypted file: the application came back up with no secret key variable set,
and Rails refuses to start in production without that secret, so the boot itself
is the proof. The health check answers, the root path redirects to the sign-in
form, and the session cookie is signed.

**Two criteria are deliberately left unticked.** Neither could be observed,
because production has no user yet — nobody had a session to lose, and nobody
can sign in to prove that signing in still works. Both are carried into 04,
which creates that user. The same fact is why the existing secret in the
credentials file was kept rather than replaced with the dashboard's: nothing was
signed with either, so there was nothing to preserve.

**The two carried criteria are now ticked.** Once 04 seeded the production user,
signing in and signing out were walked against the live site and both work. The
session criterion is met in the only way it can be: the secret that signs
session cookies came through the switch unchanged, so nothing that existed then
was invalidated — and nothing did exist, which is why it could not be observed
at the time.
