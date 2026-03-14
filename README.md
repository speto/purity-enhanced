# Purity Enhanced

> A beautiful, minimal and fast ZSH prompt with enhanced context and git status indicators

![screenshot](screenshot.png)

## Overview

Purity Enhanced is a fork of the original [Purity](https://github.com/therealklanni/purity) theme with improved compatibility and enhanced git status indicators. This theme works seamlessly with modern ZSH plugin managers like [antidote](https://github.com/mattmc3/antidote), [antigen](https://github.com/zsh-users/antigen), and oh-my-zsh.

### Visual Examples

**Python Data Science Project:**
```
~/ml-model (venv) 🐍 3.11 ⎇ feature/training | 2M +1 ❯
```
Shows: virtual environment, Python 3.11, feature branch with 2 modified and 1 new file

**Full-Stack Web Application:**
```
~/webapp ⬢ 18 🐘 8.2 🐳2/3 ⎇ main ❯
```
Shows: Node.js 18, PHP 8.2, Docker containers (2 running/3 total), clean main branch

**DevOps/Infrastructure:**
```
~/infra ☁ aws-prod 🏗️ staging ☸ production ⎇ main ❯
```
Shows: AWS prod profile, Terraform staging workspace, Kubernetes production context, clean main branch

**Backend Development with Jobs:**
```
~/api [✦2] 🐹 1.21 🐳1/1 ⎇ develop | 1M ❯
```
Shows: 2 background jobs, Go 1.21, Docker running, develop branch with 1 modified file

### Features

- ✨ **Beautiful and minimal** - Clean design that stays out of your way
- 🎯 **Git status indicators** - Shows detailed git status with intuitive symbols  
- ⚡ **Fast** - Fully asynchronous git operations powered by zsh-async
- 🚀 **Non-blocking** - Git operations never freeze your shell, even in large repositories
- ⏱️ **Execution time** - Shows command execution time when it exceeds threshold
- 🔴 **Smart prompt** - Prompt character turns red on command failure
- 🖥️ **SSH & Container awareness** - Shows username@host in SSH sessions, Docker containers, and Kubernetes pods
- 📁 **Informative title** - Shows current path in terminal title  
- 🔧 **Plugin manager compatible** - Works with antidote, antigen, oh-my-zsh, and more
- 💼 **Background jobs indicator** - Shows ✦ with job count when you have suspended jobs
- 🐍 **Multi-language support** - Automatically detects and shows versions for 7+ languages
- 🐳 **Docker Compose aware** - Shows running/total container counts
- ☸ **Infrastructure context** - Kubernetes, AWS, Terraform, GCP, Azure, Pulumi support
- 🔀 **Git actions** - Shows current rebase, merge, cherry-pick, or bisect status
- 🎨 **Fully customizable** - All 15+ colors can be customized via zstyle  
- ⚙️ **Performance options** - Optimizations for large repositories
- 🔧 **Context toggles** - Enable/disable individual indicators as needed

### Git Status Indicators

The theme displays git information with a clean, ccstatusline-inspired format:

- `⎇ branch-name` - Current git branch
- `𖠰 worktree-name` - Git worktree name (when applicable)
- `rebase-i`, `merge`, etc. - Current git action in progress

**File Count Display:**
- `NM` - N modified files
- `+N` Green - N added (untracked) files
- `-N` Red - N deleted files

**Optional Line Counts:**
- `(+42,-10)` - Diff statistics showing added/deleted lines (when `PURITY_GIT_SHOW_LINE_COUNTS=1`)

### Development Context Indicators

The theme intelligently detects your development environment and shows relevant context:

**Language Versions** (when project files detected):
- `💎 3.1` Ruby version (Gemfile)
- `🐍 3.11` Python version (pyproject.toml, requirements.txt, setup.py)  
- `🐹 1.21` Go version (go.mod)
- `🦀 1.75` Rust version (Cargo.toml)
- `☕ 17` Java version (pom.xml, build.gradle)
- `🐘 8.2` PHP version (composer.json)
- `⬢ 18` Node.js version (package.json)

**Infrastructure Context**:
- `🐳2/5` Docker Compose (running/total containers)
- `☸ production` Kubernetes context
- `☁ aws-prod` AWS profile
- `🏗️ staging` Terraform workspace
- `☁️ my-project` Google Cloud project
- `🌐 production` Azure subscription
- `📦 dev` Pulumi stack

**Environment Status**:
- `[✦2]` Background/suspended jobs (in brackets with count)
- `(venv-name)` Active Python virtual environment
- `user@host` Username/hostname (SSH sessions or containers)

## Installation

### [antidote](https://github.com/mattmc3/antidote)

Add to your `.zsh_plugins.txt`:
```
mafredri/zsh-async  # Required for async git operations
speto/purity-enhanced
```

Then reload with `antidote load`.

### [antigen](https://github.com/zsh-users/antigen)

Add to your `.zshrc`:
```sh
antigen bundle mafredri/zsh-async  # Required for async git operations
antigen bundle speto/purity-enhanced
antigen apply
```

### [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

First, install the required zsh-async dependency:
```sh
git clone https://github.com/mafredri/zsh-async.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-async
```

Then clone the theme repository:
```sh
git clone https://github.com/speto/purity-enhanced.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced
```

Symlink the theme file:
```sh
ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced/purity-enhanced.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced.zsh-theme
```

Add `zsh-async` to your plugins list and set the theme in your `.zshrc`:
```sh
plugins=(... zsh-async)
ZSH_THEME="purity-enhanced"
```

### [prezto](https://github.com/sorin-ionescu/prezto)

First, install the required zsh-async dependency:
```sh
git clone https://github.com/mafredri/zsh-async.git ~/.zprezto/modules/async
```

Then symlink the theme to Prezto's prompt directory:
```sh
ln -s /path/to/purity-enhanced/purity-enhanced.zsh ~/.zprezto/modules/prompt/functions/prompt_purity_enhanced_setup
```

Update your `~/.zpreztorc` to load async and set the theme:
```sh
# Add async to modules list
zstyle ':prezto:load' pmodule '...' 'async' '...'
# Set theme
zstyle ':prezto:module:prompt' theme 'purity_enhanced'
```

### Manual Installation

1. Clone the required zsh-async dependency:
   ```sh
   git clone https://github.com/mafredri/zsh-async.git
   ```

2. Clone this repository:
   ```sh
   git clone https://github.com/speto/purity-enhanced.git
   ```

3. Source both async and the theme in your `.zshrc`:
   ```sh
   source /path/to/zsh-async/async.zsh
   source /path/to/purity-enhanced/purity-enhanced.zsh
   ```

## Configuration

### Performance Options

#### `PURITY_CMD_MAX_EXEC_TIME`
Maximum execution time before showing runtime. Defaults to `5` seconds.
```sh
PURITY_CMD_MAX_EXEC_TIME=10  # Show execution time for commands longer than 10 seconds
```

#### `PURITY_GIT_SHOW_LINE_COUNTS`
Show line count statistics (+added,-deleted) in git status. Defaults to `0` (disabled).
```sh
PURITY_GIT_SHOW_LINE_COUNTS=1  # Show diff statistics like (+42,-10)
```

#### `PURITY_WORKTREE_SHOW_BRANCH`
Show branch name in worktree display. Defaults to `1` (enabled).
```sh
PURITY_WORKTREE_SHOW_BRANCH=0  # Hide branch name when in a worktree
```

### Context Indicator Toggles

Control which development context indicators are shown:

```sh
# Language version detection (default: 1 = enabled)
PURITY_SHOW_NODE=1          # Node.js version
PURITY_SHOW_RUBY=1          # Ruby version  
PURITY_SHOW_PYTHON_VERSION=1  # Python version (separate from virtualenv)
PURITY_SHOW_GO=1            # Go version
PURITY_SHOW_RUST=1          # Rust version
PURITY_SHOW_JAVA=1          # Java version
PURITY_SHOW_PHP=1           # PHP version

# Infrastructure context (default: 1 = enabled)
PURITY_SHOW_DOCKER=1        # Docker Compose status
PURITY_SHOW_KUBERNETES=1    # Kubernetes context
PURITY_SHOW_AWS=1           # AWS profile
PURITY_SHOW_TERRAFORM=1     # Terraform workspace
PURITY_SHOW_GCP=1           # Google Cloud project
PURITY_SHOW_AZURE=1         # Azure subscription
PURITY_SHOW_PULUMI=1        # Pulumi stack

# Environment indicators
PURITY_SHOW_PYTHON=1        # Python virtualenv display
```

### Color Customization

You can customize any color in the theme using `zstyle`. The format is:

```sh
zstyle :prompt:purity-enhanced:color_name color 'color_value'
```

Available color names and their defaults:

#### Core Colors
| Color Name | Default | Description |
|------------|---------|-------------|
| `path` | blue | Current directory path |
| `git:branch` | yellow | Git branch name |
| `git:action` | yellow | Git action (rebase, merge, etc.) |
| `git:added` | green | Added file count (+N) |
| `git:deleted` | red | Deleted file count (-N) |
| `git:modified` | blue | Modified file indicator |
| `prompt:success` | green | Prompt symbol when last command succeeded |
| `prompt:error` | red | Prompt symbol when last command failed |
| `execution_time` | yellow | Command execution time |
| `virtualenv` | 242 | Python virtual environment name |
| `suspended_jobs` | red | Background jobs indicator |
| `host` | 242 | Username and hostname |

#### Language Version Colors  
| Color Name | Default | Description |
|------------|---------|-------------|
| `node` | 70 | Node.js version |
| `ruby` | 196 | Ruby version |
| `python` | 226 | Python version |
| `go` | 81 | Go version |
| `rust` | 208 | Rust version |
| `java` | 214 | Java version |
| `php` | 99 | PHP version |

#### Infrastructure Colors
| Color Name | Default | Description |
|------------|---------|-------------|
| `docker` | 64 | Docker container count |
| `kubernetes` | 45 | Kubernetes context |
| `aws` | 208 | AWS profile |
| `terraform` | 214 | Terraform workspace |
| `gcp` | 33 | Google Cloud project |
| `azure` | 39 | Azure subscription |
| `pulumi` | 165 | Pulumi stack |

#### Example Color Customization

```sh
# ~/.zshrc

# Change path to cyan
zstyle :prompt:purity-enhanced:path color cyan

# Change git branch to magenta
zstyle :prompt:purity-enhanced:git:branch color magenta

# Use RGB colors (if terminal supports it)
zstyle :prompt:purity-enhanced:prompt:success color '#00ff00'

# Load the theme
source /path/to/purity-enhanced/purity-enhanced.zsh
```

### Example Configuration

```sh
# ~/.zshrc

# Performance options
PURITY_CMD_MAX_EXEC_TIME=3  # Show execution time for commands longer than 3 seconds

# Enable only desired context indicators
PURITY_SHOW_DOCKER=1        # Show Docker Compose status
PURITY_SHOW_NODE=1          # Show Node.js version
PURITY_SHOW_KUBERNETES=0    # Disable Kubernetes (if not used)
PURITY_SHOW_TERRAFORM=1     # Show Terraform workspace
PURITY_SHOW_AWS=1           # Show AWS profile

# Custom colors
zstyle :prompt:purity-enhanced:docker color 33        # Bright blue for Docker
zstyle :prompt:purity-enhanced:ruby color magenta     # Magenta for Ruby
zstyle :prompt:purity-enhanced:terraform color 99     # Purple for Terraform

# Load with your plugin manager (example with antidote)
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load
```

## Performance

Purity Enhanced has been heavily optimized for speed and responsiveness, with comprehensive performance improvements in version 0.2.0.

### Performance Metrics

**Measured Performance (Docker environment):**
- **First prompt**: 286ms (optimized initialization)
- **Render time**: 7ms (well under 50ms target)
- **Async operations**: 7ms (non-blocking git operations)
- **Memory usage**: Stable with no leaks

### Optimization Features

#### Intelligent Caching System
- **TTL-based caching**: 10x performance improvement for expensive operations
- **Automatic invalidation**: Cache updates when files or environment changes
- **Configurable TTLs**: Different cache times for fast/medium/slow operations
  - Fast operations (language versions): 5 minutes
  - Medium operations (git status): 2 minutes  
  - Slow operations (infrastructure): 10 minutes

#### Async Operations
- **Non-blocking git operations**: Large repositories won't freeze your shell
- **Progressive initialization**: Async workers start only for enabled features
- **Lazy loading**: Modules load only when needed with existence checks
- **Background processing**: Cache cleanup runs in background

### Performance Configuration

#### For Large Repositories
```sh
# Disable specific context indicators if not needed
PURITY_SHOW_DOCKER=0
PURITY_SHOW_KUBERNETES=0
PURITY_SHOW_LANGUAGES=0  # Disable all language version detection
```

#### Cache Configuration
```sh
# Adjust cache TTLs (in seconds)
PURITY_CACHE_TTL_FAST=600      # Language versions - 10 minutes
PURITY_CACHE_TTL_MEDIUM=300    # Git operations - 5 minutes  
PURITY_CACHE_TTL_SLOW=1800     # Infrastructure - 30 minutes
```

#### Async Performance
```sh
# Enable/disable async operations
PURITY_ASYNC_DOCKER=1      # Docker status (default: enabled)
PURITY_ASYNC_K8S=1         # Kubernetes context (default: enabled)
PURITY_ASYNC_LANGUAGES=1   # Language detection (default: enabled)
PURITY_ASYNC_CLOUD=1       # Cloud profiles (AWS, GCP, Azure) (default: enabled)
PURITY_ASYNC_INFRA=1       # Infrastructure tools (Terraform, Pulumi) (default: enabled)
```

### Performance Tools

#### Benchmarking
```sh
# Run performance benchmarks in Docker
make performance

# Monitor real-world performance in your shell
PURITY_DEBUG_PERF=1 zsh  # Enable performance debugging
```

For detailed performance history and improvements, see [CHANGELOG.md](CHANGELOG.md).

## Requirements

- ZSH 5.0 or newer
- Git 2.0 or newer (for git status features)
- A terminal with Unicode support
- [mafredri/zsh-async](https://github.com/mafredri/zsh-async) (for async git operations)

## Development

### Running Tests

The theme includes a comprehensive test suite with 147 tests running in Docker:

```sh
# Run all tests in Docker (recommended)
make test

# Run performance benchmarks in Docker
make performance

# Run interactive example/demo in Docker
make example
```

All testing uses Docker to ensure consistent, reproducible results across different development machines. Tests are automatically run on GitHub Actions for every push and pull request.

## Feature Comparison

### Pure vs Purity vs Purity-Enhanced

| Feature | [Pure](https://github.com/sindresorhus/pure) | [Purity](https://github.com/therealklanni/purity) | Purity-Enhanced |
|---------|------|---------|-----------------|
| **Core Features** |
| Async git operations | ✅ Full | ✅ Full | ✅ Full |
| Command execution time | ✅ | ✅ | ✅ |
| Error state indication | ✅ | ✅ | ✅ |
| Git branch display | ✅ | ✅ | ✅ |
| Git dirty state | ✅ | ✅ | ✅ |
| SSH/container awareness | ✅ | ✅ | ✅ |
| **Git Features** |
| Git status format | ✅ Symbols | ✅ Symbols | ✅ File counts (ccstatusline-style) |
| Git action display | ❌ | ❌ | ✅ (rebase, merge, etc.) |
| Git worktree support | ❌ | ❌ | ✅ |
| **Development Context** |
| Python virtualenv | ✅ | ❌ | ✅ |
| Multi-language detection | ❌ | ❌ | ✅ 7+ languages |
| Docker integration | ❌ | ❌ | ✅ Container counts |
| Kubernetes context | ❌ | ❌ | ✅ |
| Cloud profiles (AWS/GCP/Azure) | ❌ | ❌ | ✅ |
| Infrastructure tools | ❌ | ❌ | ✅ Terraform/Pulumi |
| Background jobs indicator | ❌ | ❌ | ✅ |
| **Advanced Features** |
| Transient prompt | ✅ | ❌ | ✅ 3 styles |
| VI mode support | ✅ | ❌ | ❌ |
| Comprehensive caching | ❌ | ❌ | ✅ TTL-based |
| Performance monitoring | ❌ | ❌ | ✅ Debug modes |
| **Technical** |
| Installation method | npm required | Plugin managers | Plugin managers |
| Dependencies | Node.js, zsh-async | zsh-async | zsh-async |
| Customization | Basic | Basic | 20+ colors via zstyle |
| Configuration options | ~10 | ~5 | 50+ |
| Oh-My-Zsh compatible | ❌ | ✅ | ✅ |

### Feature Implementation Details

**🔄 Inherited from Purity (original fork):**
- Oh-My-Zsh compatibility and integration
- Basic prompt structure and layout
- Prompt substitution handling (setopt prompt_subst)
- Initial git functions framework
- Color scheme foundation
- Username/hostname display logic

**✅ Implemented from Pure:**
- Async git operations (via zsh-async)
- Command execution time display
- SSH/container context detection
- Git branch and dirty state
- Prompt character color change on error
- Terminal title updates
- Performance optimizations
- Transient prompt (3 configurable styles)

**✨ Unique to Purity Enhanced:**
- Git action display (rebase, merge, cherry-pick status)
- File count git status format (ccstatusline-inspired)
- Git worktree support
- Multi-language detection (7+ languages)
- Docker integration (container counts)
- Kubernetes context display
- Cloud profiles (AWS, GCP, Azure)
- Infrastructure tools (Terraform, Pulumi)
- Background jobs indicator
- Comprehensive TTL-based caching
- Debug modes for performance monitoring

## Recommended Setup

For the best visual experience, I recommend:

- **Terminal**: macOS Terminal, [Ghostty](https://ghostty.org/), or your preferred terminal emulator
- **Font**: [JetBrains Mono](https://www.jetbrains.com/lp/mono/) or [Source Code Pro](https://github.com/adobe/source-code-pro) at 12-14pt
- **Color Scheme**: [Solarized Dark](https://ethanschoonover.com/solarized/) or [Dracula](https://draculatheme.com/)

## Testing

Testing is done exclusively via Docker to ensure consistency across environments:

```bash
# Run all tests
make test

# Run performance benchmarks
make performance

# Run interactive example
make example
```

The Docker test environment includes Ubuntu 22.04 with zsh, git, zsh-async, zunit, and all required dependencies pre-installed.

## Troubleshooting

### Execution time always showing

Adjust `PURITY_CMD_MAX_EXEC_TIME` to a higher value, or set it to a very high number to effectively disable it:
```sh
PURITY_CMD_MAX_EXEC_TIME=99999
```

## License

MIT © [Stefan Petovsky](https://github.com/speto)

Original Purity theme by [Kevin Lanni](https://github.com/therealklanni)

## Acknowledgments

- [Kevin Lanni](https://github.com/therealklanni) for the original [Purity](https://github.com/therealklanni/purity) theme
- [Sindre Sorhus](https://github.com/sindresorhus) for the original [Pure](https://github.com/sindresorhus/pure) prompt that inspired Purity
