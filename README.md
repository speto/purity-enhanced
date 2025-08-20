# Purity Enhanced

> A beautiful, minimal and fast ZSH prompt with enhanced context and git status indicators

![screenshot](screenshot.png)

## Overview

Purity Enhanced is a fork of the original [Purity](https://github.com/therealklanni/purity) theme with improved compatibility and enhanced git status indicators. This theme works seamlessly with modern ZSH plugin managers like [antidote](https://github.com/mattmc3/antidote), [antigen](https://github.com/zsh-users/antigen), and oh-my-zsh.

### Visual Examples

**Python Data Science Project:**
```
~/ml-model (venv) 🐍 3.11 git:feature/training ✶✩ ❯
```
Shows: virtual environment, Python 3.11, feature branch with modified files

**Full-Stack Web Application:**
```
~/webapp ⬢ 18 🐘 8.2 🐳2/3 git:main ↑1 ✓ ❯
```
Shows: Node.js 18, PHP 8.2, Docker containers (2 running/3 total), 1 unpushed commit

**DevOps/Infrastructure:**
```
~/infra ☁ aws-prod 🏗️ staging ☸ production git:main ✓ ❯
```
Shows: AWS prod profile, Terraform staging workspace, Kubernetes production context

**Backend Development with Jobs:**
```
~/api [✦2] 🐹 1.21 🐳1/1 git:develop ✓✶ ❯
```
Shows: 2 background jobs, Go 1.21, Docker running, staged and modified files

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

The theme displays git information with the following indicators:

- `git:branch-name` - Current git branch
- `↑N` Green - N unpushed commits ahead of remote
- `↓N` Red - N commits behind remote (available to pull)
- `✓` Green - Staged changes
- `✶` Blue - Modified files
- `✗` Red - Deleted files
- `➜` Magenta - Renamed files
- `═` Yellow - Unmerged files
- `✩` Cyan - Untracked files
- `⚑` Magenta - Stashed changes
- `⇣` Cyan - Updates available from remote (legacy indicator)
- `rebase-i`, `merge`, etc. - Current git action in progress

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

Clone the repository:
```sh
git clone https://github.com/speto/purity-enhanced.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced
```

Then symlink the theme file:
```sh
ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced/purity-enhanced.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/purity-enhanced.zsh-theme
```

Set `ZSH_THEME="purity-enhanced"` in your `.zshrc`.

### [prezto](https://github.com/sorin-ionescu/prezto)

Symlink the theme to Prezto's prompt directory:
```sh
ln -s /path/to/purity-enhanced/purity-enhanced.zsh ~/.zprezto/modules/prompt/functions/prompt_purity_enhanced_setup
```

Then set in `~/.zpreztorc`:
```sh
zstyle ':prezto:module:prompt' theme 'purity_enhanced'
```

### Manual Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/speto/purity-enhanced.git
   ```

2. Source the theme in your `.zshrc`:
   ```sh
   source /path/to/purity-enhanced/purity-enhanced.zsh
   ```

## Configuration

### Performance Options

#### `PURITY_CMD_MAX_EXEC_TIME`
Maximum execution time before showing runtime. Defaults to `5` seconds.
```sh
PURITY_CMD_MAX_EXEC_TIME=10  # Show execution time for commands longer than 10 seconds
```

#### `PURITY_GIT_PULL`
Enable/disable automatic git fetch checking. Defaults to `1` (enabled).
```sh
PURITY_GIT_PULL=0  # Disable automatic git fetch
```

#### `PURE_GIT_UNTRACKED_DIRTY`
Include untracked files in dirty check. Set to `0` for better performance in large repos.
```sh
PURE_GIT_UNTRACKED_DIRTY=0  # Don't check untracked files (faster for large repos)
```

#### `PURE_GIT_DELAY_DIRTY_CHECK`
Time to delay git dirty checking when `git status` is slow. Defaults to `1800` seconds.
```sh
PURE_GIT_DELAY_DIRTY_CHECK=60  # Wait 1 minute before checking again
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
| `git:ahead` | green | Unpushed commits indicator (↑N) |
| `git:behind` | red | Available updates indicator (↓N) |
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
PURITY_GIT_PULL=1           # Enable git pull indicator (default)

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


## Requirements

- ZSH 5.0 or newer
- Git 2.0 or newer (for git status features)
- A terminal with Unicode support
- [mafredri/zsh-async](https://github.com/mafredri/zsh-async) (for async git operations)

## Development

### Running Tests

The theme includes a test suite to ensure everything works correctly:

```sh
# Run all tests
make test

# Or directly
tests/run.sh

# Run performance benchmarks (measures real-world prompt performance)
tests/performance-benchmark.sh
```

Tests are automatically run on GitHub Actions for every push and pull request.

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
| Basic git symbols | ✅ 3 symbols | ✅ 4 symbols | ✅ 7 symbols |
| Git fetch indicator | ✅ | ✅ | ✅ |
| Unpushed/unpulled commits | ✅ | ❌ | ✅ |
| Git stash indicator | ✅ | ✅ | ✅ |
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
- Git fetch indicator (⇣)
- Unpushed/unpulled commit counts (↑N ↓N)
- Prompt character color change on error
- Terminal title updates
- Performance optimizations
- Transient prompt (3 configurable styles)

**✨ Unique to Purity Enhanced:**
- Git action display (rebase, merge, cherry-pick status)
- Extended git symbols (7 vs Pure's 3, Purity's 4)
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

```bash
# Run tests in Docker (recommended)
make test

# Run tests locally (requires dependencies)
./tests/install-deps.sh  # First time only
make test-local
```

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
