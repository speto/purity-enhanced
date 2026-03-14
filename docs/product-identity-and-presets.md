# Product Identity and Preset Contract

## Purpose

This document defines the richer prompt product direction that will evolve separately from the current `purity-enhanced` line.

The goal is a prompt that remains visually calm and fast, but is more worktree-aware and context-capable than the existing theme.

## Relationship to `purity-enhanced`

- `purity-enhanced` remains the stable existing line.
- The richer prompt is a new product line.
- It may later receive a new public name.

This split exists to preserve trust with current users while allowing the richer line to adopt clearer defaults, stronger Git/worktree semantics, and a more explicit architecture.

## Working Naming Direction

Naming is not finalized, but current criteria are:

- must still feel related to Purity
- must support preset-driven positioning
- must not sound contradictory or like a gimmick
- must not imply the old theme was broken

Current stronger naming directions:

- `purity-expanded`
- `purity-flex`
- `purity-spectrum`

Current weaker directions:

- `purity-rich`
- `purity-reloaded`

Until naming is finalized, this document refers to the new line as the `richer prompt`.

## Product Principles

1. Fast by default
   - prompt should feel immediate in normal local workflows

2. Calm by default
   - the default preset must not feel like a dashboard

3. Git/worktree first
   - Git context is the primary differentiator

4. Local context over remote context
   - local, cheap, high-signal data comes before network-backed or slow data

5. Presets over option sprawl
   - users choose a mode first; detailed knobs come later

6. Richness by layering, not by default clutter
   - more information should appear through intentional preset progression

## Presets

### `minimal`

Goal:

- stay close in spirit to the current `purity-enhanced` / classic Purity experience

Expected content:

- path
- branch
- git action when relevant
- concise dirty signal
- execution time when threshold exceeded
- exit/error prompt state
- maybe SSH / venv when obviously active and cheap

Expected omissions:

- Docker
- Kubernetes
- cloud / infra context
- CI
- broad runtime sweep
- verbose Git counts by default

Who it serves:

- users who want a clean prompt with better Git semantics than Pure, but not a context-heavy shell

### `balanced`

Goal:

- become the likely default for the richer product line

Expected content:

- everything in `minimal`
- smarter worktree-role display
- better branch/worktree shortening and de-duplication
- stronger Git status representation than a single dirty marker
- maybe jobs / local environment hints when cheap and obvious

Expected omissions:

- no CI by default
- no heavy cloud/infrastructure sweep by default
- no network-backed prompt segments

Who it serves:

- developers who live in Git and worktrees daily and want more than Pure without turning the prompt into a dashboard

### `detailed`

Goal:

- expose richer local context for users who actively want it

Expected content:

- everything in `balanced`
- Docker / Compose
- language/runtime versions
- Kubernetes / cloud / infra context
- future optional advanced segments if they remain fast enough

Expected omissions by default:

- CI remains opt-in even here unless later proven valuable enough

Who it serves:

- context-heavy local workflows, DevOps/platform workflows, multi-worktree stacks with per-worktree services

## Core vs Optional Features

### Core across all presets

- path
- prompt success/error state
- command execution time
- branch
- git action

### Core to `balanced` and above

- worktree role awareness
- richer Git state than `minimal`
- improved naming/de-duplication rules

### Optional / heavier segments

- Docker / Compose
- language runtimes
- Kubernetes
- cloud / infra
- CI / provider-backed signals

## Default Product Contract

The richer prompt should, by default:

- feel faster and calmer than a "kitchen sink" prompt
- outperform the current `purity-enhanced` behavior in worktree-heavy workflows
- avoid repeating the same name three times across path, branch, and worktree
- make the user's repository role obvious: main checkout, linked worktree, or bare repo

## Non-Goals

- not trying to become Starship or Powerlevel10k with every module imaginable
- not making every feature always-on
- not making CI or network access part of the default prompt contract

## Decisions Deferred

- final public name
- whether a helper binary is needed in v1.5+
- exact per-preset Git visual syntax
