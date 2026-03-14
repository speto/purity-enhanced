# ADR 0001: Richer Prompt Architecture

- Status: Accepted
- Date: 2026-03-14

## Context

`purity-enhanced` started as a minimal Purity-derived prompt and later accumulated a broader feature set:

- async git operations
- worktree support
- Docker / Kubernetes / cloud / infra context
- language runtime detection
- transient prompt modes
- caching and benchmark infrastructure

Recent research and debugging showed two things clearly:

1. The richer feature set no longer fits cleanly under the original "minimal Purity fork" identity.
2. Prompt lifecycle correctness matters more than feature count. Pure remains the best architectural reference for rendering discipline, while richer prompts such as Powerlevel10k and Starship justify extra features with stronger runtimes and helpers.

The project now needs an explicit architecture decision for the richer line of development while preserving the current `purity-enhanced` line as a stable reference.

## Decision

We will treat the richer direction as a separate product line and build it with this architecture:

1. Shell-owned prompt lifecycle
   - Zsh remains the owner of hooks, rendering, prompt state, and redraw behavior.
   - Prompt correctness follows a Pure-like model: one authoritative render pipeline, batched redraws, and strict stale-result handling.

2. Segment-based prompt model
   - The prompt is composed from segments with structured state and display output.
   - Git/worktree is the primary first-class domain.
   - Docker, runtime, cloud, and infrastructure contexts are optional layers rather than unconditional core behavior.

3. Preset-first product surface
   - User-facing behavior is primarily controlled through presets:
     - `minimal`
     - `balanced`
     - `detailed`
   - Presets define defaults. Fine-grained toggles may still exist, but they are secondary.

4. No daemon in v1
   - We will not start with a daemon-backed architecture.
   - We will explicitly leave room for an optional helper binary later if profiling proves shell performance is the bottleneck.

5. Optional helper boundary
   - The architecture should make it easy to introduce a helper later for expensive computations.
   - Candidate helper responsibilities include Git metadata normalization, repository-role detection, string shortening, and future provider-backed data such as CI.

## Why This Decision

This gives the richer prompt room to evolve without forcing the current `purity-enhanced` users into a new identity or heavier defaults.

It also avoids a common failure mode: overcommitting to helper/daemon complexity before measuring whether shell logic is the actual bottleneck.

This choice intentionally combines:

- Pure's lifecycle discipline
- richer contextual capability through presets and segments
- an escape hatch for compiled helpers if and when performance data justifies them

## Alternatives Considered

### 1. Keep evolving `purity-enhanced` directly

Rejected because the product identity has already drifted. Keeping all future changes under the same identity would blur the line between a stable minimal theme and a richer developer prompt.

### 2. Fully shell-only forever

Rejected as a strict rule. Shell-native implementation is the right starting point, but the project should not forbid helpers if measured pain appears in Git or context-heavy workflows.

### 3. Daemon-backed architecture from day one

Rejected for now. Daemons are justified only when persistent state, shared cross-shell caches, or network-backed features become core enough to outweigh lifecycle and distribution complexity.

### 4. Rich prompt with dozens of equal-weight toggles

Rejected as the primary UX. Presets are the main contract. Too many equal-weight toggles make the product harder to understand and maintain.

## Consequences

### Positive

- clear split between stable minimal line and richer future line
- stronger architectural discipline around redraw and async behavior
- easier product messaging through presets
- future helper path without committing to it too early

### Negative

- some duplicated documentation and decision-making across old and new product lines
- more up-front design work before implementation
- eventual helper support will still add release engineering burden if adopted

## Architectural Boundaries

### Core lifecycle responsibilities

Owned by shell:

- `precmd` / `preexec` / `chpwd`
- prompt state updates
- redraw batching
- stale async rejection
- preset loading

### Segment responsibilities

Each segment should:

- compute or receive structured state
- render from that state according to preset rules
- avoid owning prompt redraw directly

### Future helper responsibilities

If added later, helpers should:

- be optional
- have narrow, measurable responsibilities
- avoid owning shell lifecycle

## Success Criteria

The richer prompt architecture is successful if it provides:

- a stable, race-resistant prompt lifecycle
- a clear minimal/balanced/detailed story
- fast default rendering
- non-redundant Git/worktree presentation
- room for richer local context without turning the prompt into an uncontrolled dashboard

## Non-Goals

- no daemon in v1
- no CI segment in the default prompt
- no attempt to match Starship or Powerlevel10k feature-for-feature
- no requirement to preserve all current `purity-enhanced` formatting choices

## Follow-Up Documents

- `docs/product-identity-and-presets.md`
- `docs/prompt-information-model.md`
