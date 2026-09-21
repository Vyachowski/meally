# 04 — Seed the first user from credentials

**What to build:** seeding an empty development database produces a user who can
sign in, with no password typed into a console and none written anywhere a
reader could find it. Running the seed a second time is a no-op rather than an
error. Production gets its user the same way, and how that was run is written
down so the next person does not have to invent it.

This closes the one Open item left by the authentication spec — see
[`../../authentication/spec.md`](../../authentication/spec.md), which recommended
the console precisely because a seed would have carried a password into git.
Reading the value from credentials removes that objection.

Development and production each have their own encrypted file, so each has its
own user. Tests are deliberately not part of this: the fixture keeps its own
password and needs no key, which is what lets the suite run for someone who has
none.

The key that unlocks the new development file is one directory deeper than the
pattern the repository currently ignores, so it is committable by accident until
that is fixed. Fix it before the file exists, not after.

**Blocked by:** 02 — the credentials file and its key have to exist and be
trusted in production first.

**Status:** ready-for-human — the maintainer types the two values into the
encrypted files; the seed, the ignore rule and the documentation are ordinary
work that can be done alongside.

- [ ] Seeding an empty development database produces a user who can sign in
- [ ] Seeding again changes nothing and raises nothing
- [ ] The seed contains no password of its own, and neither does any tracked
      file — the value is read from the encrypted store
- [ ] A key file cannot be committed by accident, including the new one
- [ ] The test suite still passes for someone holding no key at all
- [ ] Production has its user, and the way it was created is documented well
      enough to repeat
- [ ] The authentication spec's Open item is marked closed and points here

Context: [`../spec.md`](../spec.md) — see "Details that bite" for the ignore
gap and the idempotence requirement.
