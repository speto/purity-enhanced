# Zsh Make Completion: Files vs Targets

## The Default Behavior

**By default**, zsh's Make completion shows **both files AND targets** when you press TAB after typing `make`. This is intentional because Make can accept both:
- **Targets** from the Makefile (like `test`, `example`, `clean`, `build`)  
- **Files** as arguments (to build specific object files, source files, etc.)

For example, in a directory with a Makefile containing targets `test` and `example`, plus files like `README.md` and `main.c`, pressing TAB after `make` will show all of them mixed together.

## Why This Happens

The zsh completion system uses "tags" to categorize different types of completions. For Make, the tags are:
- `targets` - Makefile targets
- `variables` - Make variables  
- `files` - Regular files in the directory

Without configuration, zsh shows all available tags mixed together, which can be confusing when you just want to see available Make targets.

## Solutions

### Option 1: Prioritize Targets (Recommended)

Add this to your `~/.zshrc` after loading your shell framework/plugins:

```bash
# Make completion: show only targets and variables, not files
zstyle ':completion::complete:make::' tag-order 'targets variables'
```

This tells zsh to:
1. First try to complete Make targets
2. Then try Make variables  
3. Only show files if no targets/variables match what you typed

### Option 2: Never Show Files

If you want to **completely disable** file completion for Make:

```bash
# Disable file completion for make entirely
zstyle ':completion::complete:make::' file-patterns ''
```

### Option 3: Enhanced GNU Make Support

For GNU Make with included makefiles (if targets are defined in included `.mk` files):

```bash
# Force make to evaluate the Makefile to get all targets
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets'
```

This causes the completion system to actually call `make -nsp` to determine all possible targets, including those from included files. Note: This can be slower for large Makefiles.

## Testing the Configuration

After adding the configuration to your `~/.zshrc`:

1. Reload your shell:
   ```bash
   exec zsh
   ```

2. Navigate to a directory with a Makefile:
   ```bash
   cd /path/to/project
   ```

3. Test completion:
   ```bash
   make <TAB>
   ```

You should now see only Makefile targets (and variables if using Option 1), not regular files.

## Understanding tag-order

The `tag-order` style doesn't govern the order in which completions are displayed, but rather the order in which completion groups are tried. 

- If you specify `'targets variables'`, zsh will first look for matching targets, then variables
- Files will only be shown if you partially type something that doesn't match any target or variable
- Adding a hyphen `-` at the end (like `'targets variables -'`) prevents any other tags from being tried

## Troubleshooting

If the configuration doesn't work:

1. Ensure completions are properly initialized:
   ```bash
   autoload -Uz compinit && compinit
   ```

2. Check if the style is set correctly:
   ```bash
   zstyle -L | grep make
   ```

3. Clear completion cache:
   ```bash
   rm -f ~/.zcompdump*
   exec zsh
   ```

## Related Issues

This configuration is especially useful when combined with fixing completion initialization issues (see `antidote-use-omz-vs-ez-compinit.md` for related completion system conflicts).