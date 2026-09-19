# No CSS framework

**Status:** accepted, 2026-09-06

Meally has no CSS framework. Styles are written by hand against semantic HTML, in
one stylesheet. Hotwire stays — it is the Rails 8 default and this decision is
only about CSS.

The usual case for a framework is saving time for whoever writes the markup. Here
the markup is written by a coding agent, not by the maintainer, so that saving
does not apply. What is left favours hand-written CSS: the maintainer **reviews**
the markup, and semantic HTML plus one stylesheet reads far more easily than
chains of utility classes; there is nothing to update or break on a major
version; and less CSS means a faster start on a phone and less for the service
worker to cache, which matters because Meally is a PWA.

## Considered options

| Option | Why not |
|---|---|
| Tailwind + daisyUI | Judged technical debt to take on at the start |
| Web Awesome | Same argument — the markup burden it removes is not a burden here |
| Bootstrap | 226 KB of CSS and 78 KB of JS; restyling it costs more than writing our own |
| Pico CSS | No release in 18 months and the maintainer has disappeared |

## Consequences

- **Retreat threshold.** Past roughly 800 lines of stylesheet, or as soon as an
  expensive component is needed — a datepicker, a combobox, a sortable table —
  take something off the shelf for that piece. The decision is not a commitment
  to build everything.
- **Semantic tags and few classes.** No chains of utility classes: a home-grown
  Tailwind is worse than the real one, because it is undocumented.
- **Quality bar moves by stage.** A prototype for an audience of one is allowed
  to be ugly; a product for other people is separate work with its own time
  budget, not a side effect of writing markup.
- **Keep logic out of views.** There is a live hypothesis that the UI may one day
  move to React with Rails as the backend — which would undo the choice of
  Hotwire. No trigger has been defined and it is not a plan, but the one
  precaution worth taking now is cheap and pays off regardless: if the UI is ever
  replaced, only presentation should have to move.
