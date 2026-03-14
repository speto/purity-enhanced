# Research Log

This file captures prompt-theme research, architecture notes, tradeoffs, and evolving decisions.

Format:
- Timestamped sections for each major research pass
- `Question`, `Findings`, `Options`, `Current Leaning`, and `Open Questions`
- Focus on evidence-backed conclusions that can drive implementation

---

## 2026-03-14 10:00 Europe/Bratislava - Prompt Architecture and Product Direction

### Question

What should the next-generation richer fork of `purity-enhanced` optimize for, and what architecture direction makes the most sense?

### Findings

- `purity-enhanced` has outgrown a strictly minimal Purity-style scope and now behaves more like a compact, context-aware developer prompt.
- Pure remains the strongest reference for lifecycle correctness: one async model, one redraw path, and a very disciplined scope.
- Richer prompts such as Powerlevel10k and Starship justify broader feature sets with stronger runtimes/helpers rather than more shell redraw complexity.
- A promising product model is three presets:
  - `minimal`: close to classic Purity / current lean prompt
  - `balanced`: stronger git/worktree defaults
  - `detailed`: Docker and richer context features

### Options

1. Pure-like minimal async core
2. Hybrid prompt with minimal default and opt-in contexts
3. Fully rich prompt with shell-only async workers
4. Helper-backed or daemon-backed rich prompt
5. New identity for richer fork while leaving existing `purity-enhanced` largely intact

### Current Leaning

- New identity for the richer direction is plausible and may reduce identity drift.
- The most likely product shape is a hybrid prompt with presets rather than one always-on behavior.
- Worktree-heavy workflows should explicitly shape the information model; redundant path/branch/worktree repetition needs to be avoided.

### Open Questions

- What name best fits a richer descendant of Purity?
- Should the richer fork remain shell-only, or use compiled helpers / a daemon for expensive features?
- Which contexts belong in `balanced` vs `detailed` by default?

### Naming Notes

- Early naming review suggests avoiding names that sound self-contradictory or over-dramatic.
- Weak candidates:
  - `purity-rich` — understandable but flat
  - `purity-reloaded` — strong reboot connotation, feels overdone
- Stronger directions emphasize evolution or flexibility:
  - `purity-expanded`
  - `purity-flex`
  - `purity-spectrum`
- Current naming criteria:
  - must still feel related to Purity
  - must support presets like `minimal`, `balanced`, `detailed`
  - should not imply the original theme was broken

---

## 2026-03-14 10:00 Europe/Bratislava - Git Visual Research

### Question

What git prompt visual style works best for minimal and TUI-heavy workflows?

### Findings

- Popular and respected prompts cluster around a few patterns:
  - dirty marker only: `branch *`
  - compact aggregate count: `branch ~3`
  - typed counts: `branch +2 ~3 -1`
  - grouped counts: `branch [~3 +2 -1]`
- The current `| 3M` style is not invalid, but it reads like an appended segment rather than an integrated prompt token.
- Conflict state should be visually distinct in any non-trivial git mode.
- `~3` appears to be a strong middle ground: compact, readable, and still informative.

### Options

1. `⎇ branch *`
2. `⎇ branch ~3`
3. `⎇ branch +2 ~3 -1`
4. `⎇ branch [~3 +2 -1]`

### Current Leaning

- Default candidate: `⎇ branch ~3`
- Richer preset candidate: `⎇ branch +2 ~3 -1`

### Open Questions

- How should conflicts, stash, and ahead/behind be represented across presets?
- Should branch and worktree become a single higher-level repo segment rather than separate pieces?

---

## 2026-03-14 10:00 Europe/Bratislava - Context Features

### Question

How far should the prompt go with worktree, Docker, Kubernetes, language, and cloud context?

### Findings

- Most minimal prompts intentionally avoid many contexts.
- Richer prompts often make Docker/Kubernetes/cloud either opt-in, directory-scoped, timeout-guarded, helper-backed, or all of the above.
- Language/runtime versions are commonly directory-scoped and file-triggered.
- Docker/Compose and Kubernetes are among the most failure-prone prompt contexts because CLI calls can be slow and environment-dependent.

### Current Leaning

- `balanced`: likely worktree + stronger git semantics, maybe language/runtime where obvious
- `detailed`: Docker/Compose, Kubernetes, cloud/infra, richer context signals

### Open Questions

- Should CI status ever be prompt-native, or is it too stale/noisy for the default experience?
- Which contexts should be helper/daemon-backed if adopted?

---

## 2026-03-14 10:05 Europe/Bratislava - Runtime Architecture Options

### Question

What do `shell-only async`, `helper-based`, and `daemon-backed` actually mean for a prompt, and which direction fits a richer fork best?

### Findings

- `Oh My Zsh` async is still shell-native async:
  - it forks subprocesses
  - uses pipes + `zle -F` watchers
  - has no persistent daemon and no compiled helper requirement
- `Pure` / `zsh-async` use a more persistent shell-worker model via `zpty`, which is more efficient than fork-per-request once initialized.
- `Powerlevel10k` gets much of its performance edge from `gitstatusd`, a compiled helper/daemon specialized for Git metadata.
- `Starship` takes a different route entirely: prompt generation lives in a compiled binary rather than a shell-native runtime.

### Definitions

- `shell-only async`
  - prompt logic stays in shell
  - expensive work is pushed into background shell jobs/workers
  - best portability within shell ecosystems, lowest packaging burden
- `helper-based`
  - prompt remains shell-owned, but invokes a compiled external binary for expensive or structured work
  - helper can be short-lived and called on demand
  - easiest migration path if shell performance becomes the bottleneck
- `daemon-backed`
  - a long-lived background service holds state, caches expensive results, and answers prompt queries over IPC
  - highest complexity, best for truly expensive or networked features

### Tradeoffs

- `shell-only async`
  - pros: simplest distribution, easiest to iterate, keeps strong Zsh-theme identity
  - cons: shell performance ceiling, more redraw/race risks if architecture is sloppy
- `helper-based`
  - pros: major performance upside for expensive segments, moderate complexity, still shell-owned lifecycle
  - cons: release/distribution burden, cross-platform binary management
- `daemon-backed`
  - pros: strongest scaling for heavy state, CI polling, large-repo metadata, shared state across prompts
  - cons: background lifecycle, caching invalidation, install/debug complexity, weaker "simple theme" story

### Current Leaning

- New richer fork should start as:
  - shell-owned lifecycle
  - no daemon initially
  - optional helper boundary designed in advance
- If profiling later proves Git or context detection is the bottleneck, an optional Rust/Go helper is the most sensible next step.

### Open Questions

- Which segments are expensive enough to justify a helper first: Git only, or also Docker/K8s/context parsing?
- Rust vs Go if a helper is introduced?

---

## 2026-03-14 10:05 Europe/Bratislava - Worktree-First Information Model

### Question

How should the prompt present Git/worktree context in worktree-heavy workflows without repeating the same information three times?

### Findings

- In Worktrunk-style workflows, cwd, branch name, and worktree name often strongly overlap.
- Repeating path basename + branch + worktree creates visual noise without increasing understanding.
- A better model is to treat repository context as structured data rather than independent string fragments.

### Recommended Data Model

- `repo_role`: `none | main | worktree | bare`
- `repo_name`
- `branch_name`
- `worktree_name`
- `git_action`
- `dirty_summary`
- future optional: `ci_state`

### Display Rules

- Always show path first.
- Always show branch in Git repositories unless detached logic overrides.
- Show worktree label only if it adds meaning beyond cwd + branch.
- Show `bare` explicitly when inside a bare repository.
- Show `main` subtly only when that distinction matters (for example when sibling worktrees exist).
- Collapse duplicates when cwd basename, worktree name, and branch leaf all express the same idea.

### Example Direction

- instead of repeating three similar tokens:
  - `~/Workspace/apex/diana.feat-phpunit-and-tests  ⎇ feat/phpunit-and-tests 𖠰 diana.feat-phpunit-and-tests`
- prefer a condensed semantic version such as:
  - `~/Workspace/apex/diana.feat-phpunit-and-tests  wt  ⎇ feat/phpunit-and-tests`
  - or `~/Workspace/apex/diana.feat-phpunit-and-tests  ⎇ feat/phpunit-and-tests ~3`
- in a bare repo:
  - `bare repo-name`

### Current Leaning

- Worktree should be treated as repo role/context, not always as another displayed name.
- The default prompt should optimize for answering:
  1. where am I?
  2. what branch am I on?
  3. is this main checkout, linked worktree, or bare repo?

---

## 2026-03-14 10:05 Europe/Bratislava - CI Status and Worktrunk

### Question

Should CI status be shown in the prompt for GitHub/GitLab / Worktrunk-style workflows?

### Findings

- Worktrunk surfaces CI pipeline status in `wt list --full` and treats it as an explicitly richer, networked view.
- Prompt themes generally do not show CI status by default.
- Reasons prompt themes avoid CI by default:
  - network latency
  - auth/token setup burden
  - stale data
  - rate limits
  - visual noise for a state that changes independently of prompt cadence
- If prompt CI status exists, it should be:
  - async-only
  - cached aggressively (30s+)
  - opt-in
  - provider-aware (GitHub vs GitLab)

### Current Leaning

- CI status should not be part of the default experience.
- It may be a good future `detailed` or `experimental` segment, especially for worktree-heavy users.
- Worktrunk's `--full` behavior is a good reference for UX and caching expectations.

---

## 2026-03-14 10:05 Europe/Bratislava - Product Shape Recommendation

### Question

What is the most sensible product direction for the richer fork?

### Findings

- Oracle recommends treating the richer prompt as a new product line rather than the next state of `purity-enhanced`.
- Presets should be the primary user-facing surface, not dozens of independent knobs.
- The richer fork should still let shell own lifecycle correctness, taking Pure as the rendering model reference.

### Recommended Presets

- `minimal`
  - cwd
  - branch
  - action
  - concise dirty signal
  - exec time
  - maybe venv / ssh when obviously active
- `balanced` (likely default)
  - everything in `minimal`
  - smarter worktree-role display
  - improved Git/worktree shortening
  - maybe jobs / local env cues when cheap and obvious
- `detailed`
  - everything in `balanced`
  - Docker/Compose
  - language/runtime versions
  - Kubernetes / cloud / infra context
  - CI only if explicitly enabled later

### Current Leaning

- Preserve current `purity-enhanced` as the stable line.
- Explore a new identity for the richer fork.
- Start with shell-owned lifecycle + segment/preset system.
- Defer daemon architecture until measured pain clearly justifies it.
