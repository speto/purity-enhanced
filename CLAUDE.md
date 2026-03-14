# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Purity Enhanced is a ZSH prompt theme that provides a minimal, fast, and informative command-line experience with enhanced git status indicators. It's designed to work seamlessly with various ZSH plugin managers (antidote, antigen, oh-my-zsh, prezto).

## Key Architecture

### Main Components

1. **purity-enhanced.zsh** - Core theme implementation containing:
   - Prompt rendering functions (`prompt_purity_enhanced_precmd`, `prompt_purity_enhanced_preexec`)
   - Git status detection and display logic
   - Execution time tracking
   - Fallback git functions for environments without oh-my-zsh

2. **purity-enhanced.zsh-theme** - Symbolic link to purity-enhanced.zsh for oh-my-zsh compatibility

3. **arch/PKGBUILD** - Arch Linux package build configuration

### Important Functions

- `prompt_purity_enhanced_setup()` - Main initialization function that configures prompt variables and hooks
- `prompt_purity_git_info()` - Displays git branch, worktree, and action status (ccstatusline-inspired format)
- `prompt_purity_git_status()` - Shows file counts in ccstatusline format (NM modified, +N added, -N deleted)
- `prompt_purity_enhanced_git_branch_sync()` - Synchronous branch display for immediate prompt rendering
- `prompt_purity_enhanced_chpwd()` - Directory change handler for cache invalidation
- `prompt_purity_enhanced_async_tasks()` - Centralized async job queuing for non-blocking operations
- `prompt_purity_enhanced_cmd_exec_time()` - Tracks and displays command execution time

*Note: `git_prompt_info()` and `git_prompt_status()` are provided as compatibility aliases when oh-my-zsh is not loaded.*

### Configuration Variables

- `PURITY_CMD_MAX_EXEC_TIME` - Threshold for showing execution time (default: 5 seconds)
- `PURITY_GIT_SHOW_LINE_COUNTS` - Show line count statistics (+added,-deleted) in git status (default: 0)
- `PURITY_WORKTREE_SHOW_BRANCH` - Show branch name in worktree display (default: 1)

## Common Development Tasks

### Testing Theme Changes

To test modifications to the theme:

```bash
# Source the theme directly in current shell
source ./purity-enhanced.zsh

# Or reload your shell configuration
source ~/.zshrc
```

### Verifying Plugin Manager Compatibility

The theme should work with multiple plugin managers. Test installation methods:

- **antidote**: Add `speto/purity-enhanced` to `.zsh_plugins.txt`
- **antigen**: Use `antigen bundle speto/purity-enhanced`
- **oh-my-zsh**: Requires symlink creation as documented in README
- **Manual**: Direct sourcing in `.zshrc`

### Git Status Indicators Reference

When modifying git status display:
- `⎇ branch` - Git branch (sync display)
- `𖠰 worktree` - Git worktree name (when applicable)
- `NM` - N modified files
- `+N` Green - N added files
- `-N` Red - N deleted files
- `(+N,-N)` - Line counts (optional via PURITY_GIT_SHOW_LINE_COUNTS=1)
- `rebase-i`, `merge`, etc. - Current git action in progress

## Testing

**IMPORTANT: Always run tests via Docker - do not try any other testing methods.**

### Running Tests

Use the Makefile commands or Docker directly to run tests in the proper containerized environment:

```bash
# Run all tests
make test
# OR
docker run --rm purity-test

# Run specific test suite
docker run --rm purity-test zunit tests/unit/core.zunit 2>&1 | tail -50
docker run --rm purity-test zunit tests/unit/git.zunit 2>&1 | tail -50
docker run --rm purity-test zunit tests/unit/async.zunit 2>&1 | tail -50
docker run --rm purity-test zunit tests/unit/contexts.zunit 2>&1 | tail -50

# Run interactive example/demo
make example
```

### Test Infrastructure

- **Dockerfile**: Multi-stage build with `test` target that includes zunit, revolver, and all test dependencies
- **Makefile**: Provides `make test` command that builds and runs the Docker test container
- **tests/run.sh**: Main test runner script executed inside the container
- **Container Environment**: Ubuntu 22.04 with zsh, git, zsh-async, zunit, and all required dependencies pre-installed

The Docker test environment ensures consistent, reproducible test results across different development machines.

### Testing Approaches

**Unit Tests**: Use mocks for isolated testing of individual functions
- Mock async, git, and other external dependencies
- Fast execution, no external requirements
- Located in `tests/unit/`

**Integration Tests**: Use `zpty` for interactive shell testing with real async support
- Test actual async callbacks with ZLE (ZSH Line Editor) 
- Real git operations and worktree detection
- Located in `tests/integration/`
- See `docs/testing-zpty-async.md` for detailed documentation

### Interactive Testing with zpty

For testing features that require async callbacks (like git worktree detection), we use `zpty` which creates interactive shell sessions where ZLE is active and async callbacks can fire properly.

```bash
# Example integration test structure
@test 'async worktree detection' {
    local session="test_$$"
    
    # Start interactive session with ZLE and async
    zpty_start_session "$session"
    zpty_load_theme "$session"
    
    # Test async operations
    zpty_test_async_operations "$session" 5
    
    # Verify results
    # ... assertions ...
    
    # Clean up
    zpty_cleanup_session "$session"
}
```

This approach ensures tests catch issues with async operations that traditional shell testing misses.

## Commit Guidelines

### CHANGELOG.md Updates
When making significant changes, always update CHANGELOG.md:
- **Features** (feat) → Added section  
- **Bug fixes** (fix) → Fixed section
- **Refactoring** (refactor) → Changed section
- **Performance** (perf) → Changed section with performance note
- **Documentation** (docs) → Changed section
- **Tests** (test) → Changed section

Use the `/commit` command which automatically offers to update CHANGELOG.md for qualifying changes.

### Commit Message Format
Follow conventional commits with emojis:
```
<emoji> <type>(<scope>): <description>

Examples:
✨ feat(git): add new status indicator
🐛 fix(async): resolve worker initialization issue  
♻️ refactor(perf): restructure benchmark system
```

## Development Notes

- The theme uses ZSH prompt substitution (`setopt promptsubst`) for dynamic content
- Async git pull checking runs in background to avoid blocking the prompt
- Fallback implementations ensure the theme works without oh-my-zsh dependencies
- ANSI escape sequences are used for cursor positioning in async operations