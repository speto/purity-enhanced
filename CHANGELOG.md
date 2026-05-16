# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Compose-file gate for Docker context** (`_purity_has_compose`): `docker ps` now only runs in directories containing a Compose project file. Recognises `docker-compose.{yml,yaml}`, `compose.{yml,yaml}`, `*.override.*` variants, **`.devcontainer/docker-compose.yml`** (devcontainer pattern), and **`$COMPOSE_FILE`** env var override (Docker Compose's own mechanism). Walks up to git root or filesystem root. Eliminates docker socket traffic from `$HOME` and non-project directories.

- **Directory gates for cloud/k8s context** (mirroring the docker pattern):
  - `_purity_has_kube_config`: gates kubectl context on `$KUBECONFIG` or `~/.kube/config`. Prevents kubectl invocations in directories where Kubernetes isn't configured (defends against slow `exec` auth providers).
  - `_purity_has_gcp_config`: gates gcloud on `$GCLOUD_PROJECT`, `$CLOUDSDK_CORE_PROJECT`, `$CLOUDSDK_CONFIG`, or `~/.config/gcloud/`.
  - `_purity_has_azure_config`: gates `az account show` on `$AZURE_SUBSCRIPTION_ID` or `~/.azure/`.
- **Portable timeout fallback** in `_purity_timeout`: added `perl -e 'alarm shift; exec @ARGV'` as Tier 3 between `gtimeout` and the bare-exec last resort. Perl ships with macOS by default, so wedged Docker daemons (e.g. OrbStack crash loops) no longer block the prompt on systems without GNU coreutils.
- **`_purity_is_timeout_exit` helper**: DRY check for both `124` (GNU timeout) and `142` (perl/SIGALRM) timeout exit codes. Used by k8s/gcloud/az callers.


### Changed
- **Docker detection reverted to async** (it had been temporarily sync). Combined with the new Compose-file gate, the prompt is non-blocking when the docker daemon is slow or down. Removed `prompt_purity_enhanced_sync_docker` wrapper and its precmd call.
- **Docker context: no cache for runtime state** (research-backed via Spaceship-prompt, lazydocker, k9s analysis): `prompt_purity_enhanced_async_docker_status` no longer caches container counts. Container start/stop now reflects in the prompt on the next async refresh (~next precmd) instead of waiting for `PURITY_CACHE_TTL_MEDIUM` to expire. Cost is acceptable (10-50ms `docker ps` in async worker, bounded by `_purity_timeout 3`).
  - Split into individual benchmark scripts (first-prompt, render-time, memory-stability, async-operations)
  - Added orchestrator script maintaining original output format and metrics
  - Enabled individual benchmark execution for targeted testing
  - Improved maintainability while preserving all original measurements
- **Prompt architecture**: Moved to a single authoritative render path and consolidated async workers
- **Git status rendering**: Added preset-aware styles (`*`, `~N +N -N`, `[~N +N -N]`) with conflict markers
- **Context gating**: Wired Docker/runtime/cloud segments to preset flags and explicit overrides
- **Docker context detection**: Switched to label-based Compose project matching (`com.docker.compose.project`)
- **Test coverage**: Expanded unit/integration tests for presets, repo-role detection, worktree de-duplication, and context rendering

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- **Prompt hang when docker daemon is wedged on macOS without coreutils**: a crash-looping OrbStack/Docker Desktop daemon could freeze the prompt indefinitely because `_purity_timeout` silently fell through to running `docker ps` with no timeout when neither `timeout` nor `gtimeout` was installed. Now protected by the perl `alarm` fallback (Tier 3) which kills hanging commands in the configured timeout window (exit code 142).
- **`docker ps` running in every directory**: previously the docker check fired on every prompt anywhere `docker` was installed; now gated by `_purity_has_compose`.
- **kubectl/gcloud/az running in every directory**: same class of issue — these now require a real config to be present (env var or config file), reducing per-prompt subprocess churn and the chance of a slow auth-provider/token-refresh stalling the worker.
- **Stale docker container counts after `docker stop`**: prompt previously displayed cached "running=N" for up to `PURITY_CACHE_TTL_MEDIUM` after containers stopped (compose-file mtime didn't change). Now runtime state is always re-probed.

- **Timeout exit-code handling**: callers in `async_k8s_context`, `gcloud`, and `az` paths now accept both `124` (GNU timeout) and `142` (perl/SIGALRM) as timeout signals when caching the timeout state. Factored into a `_purity_is_timeout_exit` helper to prevent future drift.
- **Docker test image hygiene**: `make test` and `make performance` now prune only project-labeled dangling test images to prevent accumulation after repeated test runs

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
