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

- [ ] The deployed application serves requests with no secret key variable set
      on the platform
- [ ] A session that was live before the switch is still live after it
- [ ] Signing in and signing out both still work on production
- [ ] A deploy from a clean checkout succeeds, and the health check answers
- [ ] The deployment doc's variable table matches the dashboard exactly —
      no variable listed that is not set, none set that is not listed
- [ ] The master key is in the password manager before it is needed anywhere

Context: [`../spec.md`](../spec.md) — see "Details that bite" for why the
existing secret value has to be reused, and why the image build needs no key.
