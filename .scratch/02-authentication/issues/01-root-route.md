# 01 — A home page

**What to build:** visiting `/` renders a page instead of routing nowhere.

Sign-in has no landing place until this exists: the generated `Authentication`
concern sends a successful sign-in to `root_url`, and root is commented out — the
redirect would raise. Ticket 02 cannot be verified without it.

The page must say **nothing about the signed-in user**. `Current.user` and the
session routes arrive with the generator in 02, and a page that references them
before then cannot boot. It ends up behind the login on its own, because the
concern is included into the base controller.

Content is a placeholder on purpose. The domain model is unsettled — a skeleton
with empty cards for weight and waist would be designing the product through
markup, and would be rebuilt whole.

Name it after `home`, not `dashboard`. This is the project's first domain term
and will land in the glossary; "dashboard" already claims the page shows a
summary that has not been designed.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [x] `GET /` responds 200 and renders a page
- [x] Nothing in the controller, view or route refers to users, sessions or
      authentication
- [x] An integration test covers it, and CI reports the test actually ran
- [x] `bin/rubocop` is clean

Context: [`../spec.md`](../spec.md). Note for 02: the test written here asserts a
200, which stops being true once authentication lands.

Delivered by the home-page pull request, merged 2026-09-21.
