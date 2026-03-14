# Antidote: use-omz vs ez-compinit - Why You Shouldn't Use Both

## The Problem
When using Antidote with both `mattmc3/ez-compinit` and `getantidote/use-omz`, completion systems may fail silently. Common symptoms include:
- Make targets showing files instead of targets when pressing TAB
- Other command completions not working properly
- Completions only working after manually calling `compinit`

## What Each Plugin Does

### ez-compinit
**Purpose:** A standalone, universal zsh completion optimizer
- **Deferred loading:** Delays `compinit` until first prompt for faster startup
- **Smart caching:** Manages `zcompdump` with configurable cache policies
- **Compstyle system:** Provides switchable completion style presets (ohmy, prez, gremlin, zshzoo)
- **Framework agnostic:** Works with vanilla zsh, prezto, or any setup
- **Configuration:** Uses zstyle for customization

### use-omz  
**Purpose:** Oh-My-Zsh compatibility layer for Antidote
- **OMZ integration:** Sets up `$ZSH` environment and makes OMZ plugins work
- **Deferred loading:** Also implements deferred `compinit` (conflicts with ez-compinit!)
- **Advanced caching:** Tracks fpath changes via metadata, rebuilds when plugins change
- **Security features:** Integrates `compfix.zsh` for insecure directory detection
- **Host-specific:** Creates per-host cache files for multi-machine setups

## The Conflict
Both plugins create wrapper functions for `compinit`. Since `use-omz` loads after `ez-compinit` (when listed in that order), it overwrites ez-compinit's wrapper, essentially disabling it. This creates a situation where:
1. `ez-compinit` sets up its deferred loading system
2. `use-omz` overwrites it with its own
3. The completion system may not initialize properly
4. Users experience broken completions

## Which Should You Use?

### Use ONLY `use-omz` if:
- You're using ANY Oh-My-Zsh plugins (git, docker, npm, etc.)
- You want OMZ compatibility
- You need the security features

### Use ONLY `ez-compinit` if:
- You're NOT using any Oh-My-Zsh plugins
- You want the compstyle preset system
- You prefer a minimal, framework-agnostic solution

### Never use both!
The overlapping functionality creates conflicts with no benefits. Pick one based on your needs.

## Fix for Existing Setups
If you have both, remove `ez-compinit` from your `.zsh_plugins.txt`:
```bash
# Comment out or remove this line:
# mattmc3/ez-compinit

# Keep this if using OMZ plugins:
getantidote/use-omz
```

Then regenerate and clear cache:
```bash
antidote update
rm -f ~/.zcompdump* ~/.cache/zsh/zcompdump*
exec zsh
```

## Conclusion
While both plugins optimize completion loading, they're mutually exclusive. Choose based on whether you need Oh-My-Zsh compatibility (use-omz) or want a minimal, universal solution (ez-compinit). For most Antidote users leveraging OMZ's rich plugin ecosystem, `use-omz` is the right choice.