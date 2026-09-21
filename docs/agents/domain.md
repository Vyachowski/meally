# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root — the glossary. Does not exist yet; the domain model is undecided.
- **`docs/adr/`** — read the ADRs that touch the area you're about to work in.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

## File structure

This is a single-context Rails application. Domain docs live at the repo root,
the code lives in `app/`:

```
/
├── CONTEXT.md          ← the glossary, not created yet
├── docs/adr/
│   ├── 0001-deploy-to-railway.md
│   ├── 0002-secrets-in-rails-credentials.md
│   ├── 0003-derive-solid-database-urls.md
│   └── 0004-no-css-framework.md
└── app/
```

There is no `CONTEXT-MAP.md` and no per-context `docs/adr/`. Those belong to
multi-context repositories; a Rails monolith is not one, so do not go looking for
them.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0004 (no CSS framework) — but worth reopening because…_
