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
- 🖥️ **SSH awareness** - Shows username@host only in SSH sessions
- 📁 **Informative title** - Shows current path in terminal title
- 🔧 **Plugin manager compatible** - Works with antidote, antigen, oh-my-zsh, and more

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
3. **Enhanced git indicators** - More detailed git status with additional indicators like stash status
4. **Prompt improvements** - Uses `~` for home directory in the prompt for cleaner, more compact display
5. **Bug fixes** - Fixed prompt substitution issues and improved compatibility across different ZSH configurations
6. **No npm dependency** - Simplified installation via git-based plugin managers only

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
