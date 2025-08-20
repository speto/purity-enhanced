# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- N/A

### Changed
- **Performance benchmarks**: Refactored monolithic 270-line benchmark script into modular system
  - Split into individual benchmark scripts (first-prompt, render-time, memory-stability, async-operations)
  - Added orchestrator script maintaining original output format and metrics
  - Enabled individual benchmark execution for targeted testing
  - Improved maintainability while preserving all original measurements

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [2.3.1] - 2025-08-20

### Fixed
- **Performance optimizations**: First prompt setup time reduced to 286ms in Docker environments
- **Async initialization**: Fixed timing issues with progressive worker startup
- **Cache management**: Improved cleanup performance with background processing
- **Module loading**: Added lazy loading with existence checks for better startup performance
- **Memory stability**: Eliminated memory accumulation in long-running sessions

## [2.3.0] - 2025-08-11

### Added
- **Comprehensive development context indicators**
  - Language versions: Ruby, Python, Go, Rust, Java, PHP, Node.js automatic detection
  - Infrastructure context: Docker Compose (running/total), Kubernetes, AWS, Terraform, GCP, Azure, Pulumi
  - Background jobs indicator with count display
- **Enhanced git features**
  - Commit count indicators (↑N unpushed, ↓N behind)
  - Git worktree detection and support
  - Git action display (rebase, merge, cherry-pick, bisect status)
- **Transient prompt feature**
  - Three configurable styles: minimal, command, time
  - Cleaner terminal output by minimizing previous prompts
  - Configurable via `PURITY_TRANSIENT_PROMPT`
- **Intelligent caching system**
  - TTL-based file cache providing 10x performance improvement for expensive operations
  - Automatic invalidation on file/environment changes
  - Configurable cache TTL for different operation types (fast/medium/slow)

### Changed
- **Prompt layout**: Reordered to path → [✦jobs] → context → git for better information hierarchy
- **Background jobs display**: Now shown in brackets for visual clarity
- **Path positioning**: Primary context moved to front of prompt
- **All context indicators**: Made configurable via environment variables

## [2.2.0] - 2025-08-10

### Added
- **Async git operations**: Full async support via zsh-async for non-blocking prompt updates
- **Async worker management**: Initialization, callbacks, and proper cleanup
- **Large repository support**: Non-blocking operations in repositories with many files

### Changed
- **Performance**: All git operations now run asynchronously to prevent shell freezing
- **Compatibility**: Maintained backward compatibility with sync fallback when zsh-async unavailable

## [2.1.0] - 2025-08-10

### Added
- **Python virtualenv support**: Automatic detection and display of active virtual environments
- **Git action display**: Shows current rebase, merge, cherry-pick, or bisect status
- **Color customization**: Full zstyle-based color configuration for all theme elements
- **Enhanced git indicators**: Additional symbols and status information

### Changed
- **Documentation**: Updated README.md with comprehensive configuration examples
- **Installation**: Improved plugin manager compatibility instructions

## [2.0.0] - 2025-08-10

### Changed
- **BREAKING**: Removed npm package dependency - no longer requires Node.js
- **BREAKING**: Changed installation method to plugin managers only (antidote, antigen, oh-my-zsh)
- **Installation**: Simplified to pure ZSH plugin architecture

### Removed
- **npm package**: Eliminated Node.js dependency entirely
- **Legacy installation methods**: Removed npm-based installation

### Fixed
- **Prompt substitution**: Fixed issues with prompt expansion and variable handling

## [1.0.0] - 2018-10-04

### Changed
- **Initial customization**: First major changes to original Purity theme
- **Path display**: Changed prompt path to full path with $HOME resolved as ~
- **Fork establishment**: Established independent development from original Purity

## [0.1.3] - 2014-04-03

### Added
- Basic git status indicators
- Initial Oh-My-Zsh compatibility

### Fixed
- Git repository detection improvements

## [0.1.2] - 2014-03-30

### Added
- Enhanced color scheme
- Improved git integration

### Changed
- Updated screenshot and documentation

## [0.1.1] - 2014-03-30

### Added
- Initial fork of original Purity theme
- Basic ZSH prompt functionality
- Git branch and status display
- Command execution time tracking
- SSH/remote session awareness

[Unreleased]: https://github.com/speto/purity-enhanced/compare/v2.3.1...HEAD
[2.3.1]: https://github.com/speto/purity-enhanced/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/speto/purity-enhanced/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/speto/purity-enhanced/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/speto/purity-enhanced/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/speto/purity-enhanced/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/speto/purity-enhanced/compare/v0.1.3...v1.0.0
[0.1.3]: https://github.com/speto/purity-enhanced/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/speto/purity-enhanced/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/speto/purity-enhanced/releases/tag/v0.1.1