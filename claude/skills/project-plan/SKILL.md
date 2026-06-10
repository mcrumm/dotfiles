---
name: project-plan
description: Author or edit homelab project-plan frontmatter (PROJECT.md, .project/plans/*.md) against the projects-dashboard schema. Use whenever creating a plan file, changing a plan or phase state, marking a phase done, or shipping/superseding/deferring a project in any git.lan/homelab repo — including repos with no CLAUDE.md (homelab, ttrpg). Always finish by running `lab project check`.
---

# Project-plan frontmatter

Every `git.lan/homelab/*` repo tracks work in `PROJECT.md` (repo
root) and/or `.project/plans/*.md`. The YAML frontmatter feeds the
projects dashboard (kb.lan + Grafana); schema errors make the project
invisible there, so they must not land.

**The contract: after every edit to a plan file, run**

```
lab project check            # whole repo (PROJECT.md + .project/plans)
lab project check <file>     # just the file you touched
```

Exit 0 = valid. Exit 2 prints one reason per line on stderr naming
the violated rule — fix and re-run before moving on. (A PostToolUse
hook and the global pre-commit run the same check; CI gates on it
too. Getting it right immediately avoids all three.)

## Shape

```yaml
---
name: my-plan            # kebab-case slug, unique across all repos
title: One-line human title
state: planning          # planning | in-progress | shipped
                         # | superseded | deferred
drafted: 2026-06-01      # ISO-8601 date
updated: 2026-06-10      # ISO-8601 — bump on EVERY edit
owner: mcrumm            # optional
supersedes: []           # optional, project names
superseded_by: null      # required when state: superseded
blocked_on: []           # required non-empty when state: deferred
tags: [infra]            # optional
phases:                  # ordered, non-empty
  - {n: 1, name: build, state: done, at: 2026-06-05}
  - {n: 1.5, name: retrofit, state: skipped, at: 2026-06-06}
  - {n: 2, name: ship, state: planned}
---
```

## The rules that actually bite

In observed-frequency order (these caused 6 fix-up commits in one
week before the checker existed):

1. **`at:` is required** on every phase that is not `planned` — it's
   the date the phase state last changed. The terse inline form makes
   it easy to drop; don't.
2. **Enum values, not natural English.** Project: `shipped` (never
   `done`), `planning` (never `draft`). Phase: `planned | in-progress
   | done | skipped` (never `todo`).
3. **State ↔ phases must agree.** `shipped` → every phase
   `done`/`skipped`. `in-progress` → at least one phase still open.
   `planning` → no phase `done` yet.
4. **Conditional fields.** `superseded` requires `superseded_by:`;
   `deferred` requires non-empty `blocked_on:`. The phase date field
   is `at:`, never `on:` — YAML 1.1 resolves bare `on` to a boolean
   and the key silently disappears.

Required: `name`, `title`, `state`, `drafted`, `updated`, `phases`.

## Editing checklist

1. Bump `updated:` to today.
2. Phase changed state? Update its `state` **and** `at:`; append
   `✅ YYYY-MM-DD` to the phase's body heading when it ships.
3. Project changed state? Update `state` + the conditional field
   (`superseded_by` / `blocked_on`).
4. `lab project check` → exit 0 → commit.

Full contract: `docs/projects.md` in `homelab/homelab`.
