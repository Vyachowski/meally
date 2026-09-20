# A home page, so sign-in has somewhere to land

Status: ready-for-agent

## Why this is first

`after_authentication_url` in the generated `Authentication` concern falls back
to `root_url`, and `config/routes.rb` still has root commented out
(`# root "posts#index"`). A successful sign-in would raise
`ActionController::UrlGenerationError`.

Ticket 02 cannot be verified until something answers `/`.

## It must not mention authentication

This is the part that bites. Everything that would make a home page useful —
"signed in as …", a sign-out link — needs `Current.user` and `session_path`,
and **neither exists until ticket 02 runs the generator**. Referencing them here
gives a page that cannot boot.

So: a static page, no knowledge of users. Ticket 02 adds the authenticated parts
afterwards, and the page falls behind the login automatically because the
`Authentication` concern is included into `ApplicationController`.

## What to build

```ruby
# config/routes.rb
root "home#index"
```

- `HomeController#index`, empty action
- `app/views/home/index.html.erb` — a heading, and nothing else

**`HomeController`, not `DashboardController`.** This is the project's first
domain term and it will end up in `CONTEXT.md`. "Dashboard" already claims the
page shows a summary of figures; that has not been decided. "Home" claims
nothing beyond "what answers `/`".

Content is a placeholder on purpose. The domain model is unsettled — no
`CONTEXT.md`, no models — so a skeleton dashboard with empty cards for weight
and waist would be inventing the product through markup, and would be rebuilt
whole.

No CSS framework here, see
[ADR-0004](../../../docs/adr/0004-no-css-framework.md). Semantic HTML, few
classes.

## Test

An integration test that `GET /` returns 200.

**Ticket 02 will have to change it.** Once authentication exists, an
unauthenticated `GET /` redirects to the sign-in form instead — the test must
then sign in first. This is written down in 02 as well so it is not a surprise.

## Done when

`bin/rails test` passes and `/` renders in the browser.
