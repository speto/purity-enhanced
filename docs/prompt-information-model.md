# Prompt Information Model

## Purpose

This document defines the target information model for the richer prompt before implementation.

The main goal is to make Git/worktree-heavy workflows clearer while avoiding redundant display.

## Core Questions the Prompt Must Answer

1. Where am I?
2. What Git context am I in?
3. Is this the main checkout, a linked worktree, or a bare repository?
4. Is the repository clean, dirty, or mid-operation?
5. Which extra local contexts matter enough to show right now?

## Canonical Structured Model

The prompt should think in structured fields first, not in preformatted text fragments.

### Repository Fields

- `repo_role`
  - `none`
  - `main`
  - `worktree`
  - `bare`
- `repo_name`
- `branch_name`
- `branch_short`
- `detached_ref`
- `worktree_name`
- `worktree_short`
- `git_action`
- `dirty_summary`
- `ahead_count`
- `behind_count`
- `conflict_count`
- `staged_count`
- `modified_count`
- `untracked_count`
- `deleted_count`
- `stash_count`

### Path Fields

- `cwd_display`
- `cwd_basename`
- `repo_relative_path`

### Environment / Context Fields

- `venv_name`
- `runtime_contexts[]`
- `docker_context`
- `kubernetes_context`
- `cloud_contexts[]`
- `jobs_count`
- `ssh_context`

### Future Optional Fields

- `ci_state`
- `ci_provider`
- `ci_is_stale`

## Display Priorities

### Always highest priority

- path
- branch or detached state
- current git action
- basic dirty state

### High priority when meaningful

- repo role (`main`, `worktree`, `bare`)
- conflict state
- worktree identity when it adds information

### Lower priority / optional

- Docker / runtime / cloud / infra context
- ahead/behind
- stash count
- CI state

## Repository Role Rules

### `none`

- no repo-specific prompt content

### `main`

- use only when this distinction adds value
- should be subtle, not louder than branch

### `worktree`

- indicate that the checkout is a linked worktree
- do not always print the raw worktree name if path and branch already make it obvious

### `bare`

- always explicit
- this changes user expectations and valid commands

## De-Duplication Rules

The richer prompt must avoid repeating the same idea via path basename, branch name, and worktree name.

### Rule 1

If `cwd_basename == worktree_name`, do not display both unless the worktree label adds meaning beyond the path.

### Rule 2

If branch leaf and worktree name are effectively the same token, prefer showing the branch once and representing worktree as role/context instead of a second name.

### Rule 3

If a worktree folder matches cwd but branch differs meaningfully, show both.

### Rule 4

If repo role is `bare`, show that explicitly even if no branch/worktree de-duplication applies.

## Shortening Rules

Long branch/worktree names should be shortened semantically, not by naive truncation.

### Branches

- preserve meaningful prefix + distinguishing suffix where possible
- prefer `feature/.../oauth-refresh` over raw hard truncation

### Worktrees

- keep the most distinguishing suffix
- de-emphasize worktree names when branch already carries stronger meaning

### Shared budget

- when both branch and worktree are displayed, branch gets more visual budget than worktree

## Git State by Preset

### `minimal`

- branch
- action if present
- one concise dirty signal
- conflicts may still deserve a distinct override indicator

Candidate style:

- `⎇ branch *`
- or `⎇ branch ~3`

### `balanced`

- branch
- action
- repo role when meaningful
- compact but more informative dirty summary

Candidate style:

- `⎇ branch ~3`
- or `⎇ branch +2 ~3 -1`

### `detailed`

- branch
- action
- repo role
- richer dirty summary
- optional ahead/behind or stash if later justified

Candidate style:

- `⎇ branch [~3 +2 -1]`

## Example Display Intent

### Main checkout with no extra distinction needed

- `~/repo  ⎇ main ~3`

### Linked worktree where cwd already implies worktree name

- `~/repo.feature-x  wt  ⎇ feature/x ~3`

### Linked worktree where branch differs from the folder naming

- `~/repo.hotfix-shell  wt hotfix-shell  ⎇ hotfix/shell-reset *`

### Bare repository

- `~/repo.git  bare  ⎇ main`

### Mid-operation state

- `~/repo  ⎇ feature/x rebase ~3`

## Context Segment Rules

### General rule

- extra context should appear only when both relevant and cheap enough

### Docker

- belongs primarily to `detailed`
- may be exposed in `balanced` only if later proven cheap and highly valuable

### Runtime versions

- directory-scoped only
- should not appear globally just because tools are installed

### Kubernetes / cloud / infra

- default to `detailed`
- best-effort only
- must be easy to disable

### CI

- not part of the default prompt contract
- if introduced later, must be async-only, cached, and opt-in

## Non-Goals

- not every available Git datum must be visible by default
- the prompt should not echo both path and repo labels mechanically
- context segments should not override the primacy of path + Git state
