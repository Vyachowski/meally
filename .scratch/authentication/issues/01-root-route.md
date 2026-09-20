# A home page, so sign-in has somewhere to land

Status: ready-for-human

## Why this is first

`after_authentication_url` in the generated `Authentication` concern falls back
to `root_url`, and `config/routes.rb` still has root commented out
(`# root "posts#index"`). A successful sign-in would raise
`ActionController::UrlGenerationError`.

So authentication cannot be verified end to end until something answers `/`.
Ticket 02 is blocked on this one.

## Why a human

What belongs on the home page of a weight-and-nutrition tracker is a product
decision, and the domain model is explicitly unsettled — there is no
`CONTEXT.md` yet and no models at all. Nobody should invent that unattended.

## The smallest thing that unblocks 02

A controller, a route and a view. It needs to render for a signed-in user and
nothing more:

```ruby
root "home#index"
```

It will sit behind authentication automatically — the `Authentication` concern
is included into `ApplicationController`, so everything requires a session
unless it opts out with `allow_unauthenticated_access`.

Open question for whoever takes this: does the home page stay behind
authentication, or does an unauthenticated visitor see a landing page instead?
For a single user behind a Railway subdomain, behind authentication is the
simpler answer and nothing is lost by choosing it now.

Remember there is no CSS framework — see
[ADR-0004](../../../docs/adr/0004-no-css-framework.md). Semantic HTML, few
classes.
