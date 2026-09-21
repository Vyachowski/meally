# 01 — Rewrite the secrets decision

**What to build:** the decision record on secrets says that they live in Rails
credentials, unlocked by a master key, and says which values stay environment
variables and why. A reader learns the decision that holds today and nothing
else.

It is rewritten in place. No second record is added for the same subject, and
the text it replaces is overwritten rather than kept, annotated or linked to — a
decision record is not a change log, and git already holds the previous version
for anyone who wants it.

Two things from the current text belong in the new one on their own merit, not
as history: the database URL is a platform reference variable and cannot live in
a file, and the image build needs no key because asset precompilation takes a
dummy-secret branch first.

The obligation attached to the decision changes: what has to survive in a
password manager is the key files, and losing one means an unreadable file
rather than a forgotten value.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [x] The decision record states that secrets live in Rails credentials, in its
      own terms, without describing what was decided before
- [x] No additional record is created on the subject — the count of decision
      records does not grow
- [x] It lists which values remain environment variables, each with its reason
- [x] The obligation names the key files and what losing them costs
- [x] The deployment doc agrees with it — nothing there still says the master
      key is deliberately unset
- [x] Nothing in the application changes: the suite is green and CI passes

Context: [`../spec.md`](../spec.md).

Delivered by pull request #43, merged 2026-09-21. The deployment doc's variable
table is deliberately untouched — the dashboard still holds the old variable,
and ticket 02 changes both together.
