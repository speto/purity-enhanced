# Purity Enhanced

> A beautiful, minimal and fast ZSH prompt with enhanced git status indicators

![screenshot](screenshot.png)

## Overview

Purity Enhanced is a fork of the original [Purity](https://github.com/therealklanni/purity) theme with improved compatibility and enhanced git status indicators. This theme works seamlessly with modern ZSH plugin managers like [antidote](https://github.com/mattmc3/antidote), [antigen](https://github.com/zsh-users/antigen), and oh-my-zsh.

### Features

- ✨ **Beautiful and minimal** - Clean design that stays out of your way
- 🎯 **Git status indicators** - Shows detailed git status with intuitive symbols
- ⚡ **Fast** - Optimized for speed with asynchronous git pull checking
- ⏱️ **Execution time** - Shows command execution time when it exceeds threshold
- 🔴 **Smart prompt** - Prompt character turns red on command failure
- 🖥️ **SSH & Container awareness** - Shows username@host in SSH sessions, Docker containers, and Kubernetes pods
- 📁 **Informative title** - Shows current path in terminal title
- 🔧 **Plugin manager compatible** - Works with antidote, antigen, oh-my-zsh, and more
- 💼 **Background jobs indicator** - Shows ✦ when you have suspended jobs
- 🐍 **Python virtualenv** - Displays active virtual environment
- 🔀 **Git actions** - Shows current rebase, merge, cherry-pick, or bisect status
- 🎨 **Customizable colors** - All colors can be customized via zstyle
- ⚙️ **Performance options** - Optimizations for large repositories

### Git Status Indicators

The theme displays git information with the following indicators:

- `git:branch-name` - Current git branch
- `✓` Green - Staged changes
- `✶` Blue - Modified files
- `✗` Red - Deleted files
- `➜` Magenta - Renamed files
- `═` Yellow - Unmerged files
- `✩` Cyan - Untracked files
- `⚑` Magenta - Stashed changes
- `⇣` Cyan - Updates available from remote
- `rebase-i`, `merge`, etc. - Current git action in progress

### Additional Indicators

- `✦` Red - Background/suspended jobs
- `(venv-name)` Gray - Active Python virtual environment
- `user@host` Gray - Shown in SSH sessions or containers

## Installation

### [antidote](https://github.com/mattmc3/antidote)

Add to your `.zsh_plugins.txt`:
```
speto/purity-enhanced
```

Then reload with `antidote load`.

### [antigen](https://github.com/zsh-users/antigen)

Add to your `.zshrc`:
```sh
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

### Options

#### `PURITY_CMD_MAX_EXEC_TIME`

The maximum execution time of a process before its run time is shown when it exits. Defaults to `5` seconds.

```sh
PURITY_CMD_MAX_EXEC_TIME=10  # Show execution time for commands longer than 10 seconds
```

#### `PURITY_GIT_PULL`

Set `PURITY_GIT_PULL=0` to prevent Purity Enhanced from checking whether the current Git remote has been updated.

```sh
PURITY_GIT_PULL=0  # Disable automatic git fetch
```

#### `PURE_GIT_UNTRACKED_DIRTY`

Set `PURE_GIT_UNTRACKED_DIRTY=0` to exclude untracked files from the dirty check. This is useful for large repositories.

```sh
PURE_GIT_UNTRACKED_DIRTY=0  # Don't check untracked files (faster for large repos)
```

#### `PURE_GIT_DELAY_DIRTY_CHECK`

Time in seconds to delay git dirty checking when `git status` takes > 5 seconds. Defaults to `1800` seconds (30 minutes).

```sh
PURE_GIT_DELAY_DIRTY_CHECK=60  # Wait 1 minute before checking again
```

### Color Customization

You can customize any color in the theme using `zstyle`. The format is:

```sh
zstyle :prompt:purity-enhanced:color_name color 'color_value'
```

Available color names and their defaults:

| Color Name | Default | Description |
|------------|---------|-------------|
| `path` | blue | Current directory path |
| `git:branch` | yellow | Git branch name |
| `git:action` | yellow | Git action (rebase, merge, etc.) |
| `prompt:success` | green | Prompt symbol when last command succeeded |
| `prompt:error` | red | Prompt symbol when last command failed |
| `execution_time` | yellow | Command execution time |
| `virtualenv` | 242 | Python virtual environment name |
| `suspended_jobs` | red | Background jobs indicator |
| `host` | 242 | Username and hostname |

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

# Set options before loading the theme
PURITY_CMD_MAX_EXEC_TIME=3  # Show execution time for commands longer than 3 seconds
PURITY_GIT_PULL=1           # Enable git pull indicator (default)

# Load with your plugin manager (example with antidote)
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load
```

## Requirements

- ZSH 5.0 or newer
- Git 2.0 or newer (for git status features)
- A terminal with Unicode support

## Differences from Original Purity

This enhanced version includes:

1. **Better plugin manager compatibility** - Works out of the box with antidote and other modern plugin managers without requiring manual prompt initialization
2. **Self-contained** - Includes fallback git functions when oh-my-zsh is not available
3. **Enhanced git indicators** - More detailed git status with additional indicators like stash status, git actions (rebase, merge, etc.)
4. **Prompt improvements** - Uses `~` for home directory in the prompt for cleaner, more compact display
5. **Bug fixes** - Fixed prompt substitution issues and improved compatibility across different ZSH configurations
6. **No npm dependency** - Simplified installation via git-based plugin managers only
7. **Container awareness** - Detects Docker and Kubernetes environments, not just SSH
8. **Background jobs indicator** - Shows when you have suspended jobs
9. **Python virtualenv support** - Displays active virtual environments
10. **Color customization** - Full zstyle-based color customization
11. **Performance options** - Settings for large repository optimization

## Recommended Setup

For the best visual experience, I recommend:

- **Terminal**: macOS Terminal, [Ghostty](https://ghostty.org/), or your preferred terminal emulator
- **Font**: [JetBrains Mono](https://www.jetbrains.com/lp/mono/) or [Source Code Pro](https://github.com/adobe/source-code-pro) at 12-14pt
- **Color Scheme**: [Solarized Dark](https://ethanschoonover.com/solarized/) or [Dracula](https://draculatheme.com/)

## Troubleshooting

### Prompt shows literal function names

If you see `$(git_prompt_info)` instead of git information, make sure you're using a recent version. The theme now automatically enables prompt substitution.

### Git indicators not showing

The theme includes its own git functions, but for best performance with oh-my-zsh, make sure the git plugin is loaded before this theme.

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
