Why Docker Desktop Does This:
- Docker's official docs recommend adding compinit for manual zsh completion setup
- Docker Desktop auto-inserts these lines when installed/updated (especially v4.15.0+)
- It's technically "correct" for standalone Docker but creates conflicts with modern zsh setups

     Is It Best Practice? NO
     - Multiple compinit calls reset all completions and break other tools
     - Modern zsh frameworks (oh-my-zsh, prezto) and plugin managers (antidote) handle this elegantly
     - Docker Desktop has been criticized for modifying shell configs without permission (GitHub issue #6664)

     Immediate Fix

     1. Comment out Docker's duplicate compinit in ~/.zshrc (lines 48-49):
     # autoload -Uz compinit  # Commented - handled by ez-compinit
     # compinit               # Commented - handled by ez-compinit
     1. Keep line 47: fpath=(/Users/chimney/.docker/completions $fpath) - this is needed!
     2. Clear completion cache:
     rm -f ~/.zcompdump* ~/.cache/zsh/zcompdump*
     3. Reload shell and test:
     exec zsh
     cd /Users/chimney/Workspace/speto/purity-enhanced
     make <TAB>  # Should show: test, example

     Prevention Strategies for Theme Users

     Add to purity-enhanced README.md:
     ## Troubleshooting

     ### Make/Command Completion Not Working
     If tab completion stops working after installing Docker Desktop or other tools:

     1. Check for duplicate `compinit` calls in ~/.zshrc
     2. Comment out any `autoload -Uz compinit` and `compinit` lines added by:
        - Docker Desktop (look for "# Added by Docker Desktop")
        - Other tools that modify shell config
     3. Keep only the `fpath` additions, remove the compinit calls
     4. Clear cache: `rm -f ~/.zcompdump*`
     5. Restart shell: `exec zsh`

     The ez-compinit plugin (loaded via antidote) handles all completion initialization.

     Reporting to GitHub

     Where to report:
     - Docker for Mac repo: Already has issue #6664 about unauthorized shell modifications
     - Consider adding to Docker's completion docs that users should check for existing completion systems

     What to report:
     - Docker Desktop should detect existing completion systems (oh-my-zsh, antidote, etc.)
     - Should only add fpath, not force compinit
     - Should ask permission before modifying shell configs

     Long-term Solutions

     1. For purity-enhanced theme: Could add a startup check that warns if multiple compinit calls detected
     2. For Docker: They're moving toward more user-controlled installation (v4.18+)
     3. For users: Always review shell config changes after installing tools

     This issue affects many users with modern zsh setups, not just purity-enhanced theme users.




Real Root Cause Found: compinit is NOT being called at all!                                                                                                           │
│                                                                                                                                                                       │
│ The Problem                                                                                                                                                           │
│                                                                                                                                                                       │
│ After sourcing ~/.zshrc, there are 0 completions loaded and _comps[make] is not set. This means compinit is never actually being called by either ez-compinit or      │
│ use-omz.                                                                                                                                                              │
│                                                                                                                                                                       │
│ When I manually call compinit, it works perfectly - 1932 completions load including _make.                                                                            │
│                                                                                                                                                                       │
│ Why This Happens                                                                                                                                                      │
│                                                                                                                                                                       │
│ Both ez-compinit and use-omz use a deferred loading strategy via precmd hooks:                                                                                        │
│ - ez-compinit adds run-compinit to precmd hook                                                                                                                        │
│ - use-omz has its own run-compinit function that overrides ez-compinit's                                                                                              │
│ - These hooks are supposed to run on first prompt, but something is preventing them                                                                                   │
│                                                                                                                                                                       │
│ The Fix                                                                                                                                                               │
│                                                                                                                                                                       │
│ We need to ensure compinit actually runs. Three options:                                                                                                              │
│                                                                                                                                                                       │
│ Option 1: Force immediate compinit (Simplest)                                                                                                                         │
│ Add this line at the END of ~/.zshrc:                                                                                                                                 │
│ # Force compinit if not already loaded                                                                                                                                │
│ [[ ${#_comps[@]} -eq 0 ]] && autoload -Uz compinit && compinit                                                                                                        │
│                                                                                                                                                                       │
│ Option 2: Manually trigger the deferred hook                                                                                                                          │
│ Add at the end of ~/.zshrc:                                                                                                                                           │
│ # Trigger deferred compinit                                                                                                                                           │
│ run-compinit 2>/dev/null || true                                                                                                                                      │
│                                                                                                                                                                       │
│ Option 3: Add required zstyles for Make (Workaround)                                                                                                                  │
│ Add to ~/.zshrc after antidote load:                                                                                                                                  │
│ zstyle ':completion:*:make:*:targets' call-command true                                                                                                               │
│ zstyle ':completion:*:*:make:*' tag-order 'targets'                                                                                                                   │
│                                                                                                                                                                       │
│ I recommend Option 1 as it's the most reliable and will fix all completion issues, not just Make.