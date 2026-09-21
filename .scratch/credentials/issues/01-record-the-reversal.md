# 01 — Record the move back to credentials

**What to build:** a reader who opens the decision record learns that secrets
live in Rails credentials, which values stay environment variables and why, and
what they are now obliged to keep in a password manager. Nothing about how the
application behaves changes.

The existing decision says the opposite and is still marked accepted, so it has
to be superseded rather than quietly contradicted — a reader who finds it first
must be sent forward. One of its four arguments survives the reversal and has to
survive the rewrite too: the database URL is a Railway reference variable and
cannot live in a file.

The obligation changes shape rather than disappearing. Today it is "keep every
production secret in a password manager"; afterwards it is "keep the two key
files there", and the consequence of losing them is different — a lost key means
an unreadable file, not a forgotten value.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] A new decision record states that secrets live in Rails credentials, and
      lists for each value whether it moves or stays an environment variable,
      with the reason
- [ ] The superseded record says so at the top and links forward; nobody reading
      it can mistake it for current
- [ ] The argument that survives — the database URL cannot live in a file — is
      stated in the new record, not only in the old one
- [ ] The standing obligation names the two key files and what losing them costs
- [ ] The deployment doc no longer tells a reader that the master key is
      deliberately unset
- [ ] Nothing in the application changes: the suite is green and CI passes

Context: [`../spec.md`](../spec.md).
