# VHS Configuration for Purity Enhanced Theme Screenshot
# Creates a single screenshot showcasing all theme features

# Output settings
Output screenshot.png

# Terminal settings  
Set Shell "zsh"
Set Theme "Dracula"
Set FontFamily "JetBrains Mono"
Set FontSize 14
Set Width 1200
Set Height 800
Set TypingSpeed 50ms
Set Padding 20

# Initialize shell and load theme (hidden from view)
Sleep 500ms
Type "source /usr/share/zsh/site-functions/async.zsh && source /etc/zsh/purity-enhanced.zsh && prompt_purity_enhanced_setup && clear"
Enter
Sleep 1s

# 1. Show basic clean prompt in home directory
Type "# Purity Enhanced - Minimal ZSH Prompt Theme"
Enter
Sleep 1s
Type "cd ~"
Enter
Sleep 500ms

# 2. Create project directory and initialize git
Type "mkdir purity-showcase && cd purity-showcase"
Enter
Sleep 500ms
Type "git init"
Enter
Sleep 500ms

# 3. Create some files and make initial commit
Type "echo '# Purity Enhanced Demo' > README.md"
Enter
Type "git add README.md && git commit -m 'Initial commit'"
Enter
Sleep 700ms

# 4. Create mixed git state to show all indicators
Type "echo 'Modified content' >> README.md"
Enter
Type "echo 'print(hello)' > app.py"
Enter
Type "echo 'name: purity-demo' > package.json"
Enter
Type "echo 'temp files' > temp.log"
Enter
Type "git add README.md"  # Stage one file
Enter
Sleep 500ms

# 5. Create a stash to show stash indicator
Type "echo 'Work in progress' >> app.py"
Enter
Type "git stash"
Enter
Sleep 500ms

# 6. Show current state with multiple indicators
Type "clear"
Enter
Sleep 500ms
Type "# Purity Enhanced: All Git Status Indicators Demo"
Enter
Type "# ✓ staged, ✶ modified, ✩ untracked, ⚑ stashed"
Enter
Sleep 500ms

# 7. Show working directory and git status
Type "pwd"
Enter
Sleep 500ms
Type "git status --short"
Enter
Sleep 500ms

# 8. Run a command that will show execution time (>5s to trigger display)
Type "echo 'Testing execution time display...'"
Enter
Type "sleep 6"
Enter
Sleep 7s

# 9. Show error state briefly, then success
Type "nonexistent_command"
Enter
Sleep 500ms
Type "echo 'Success - prompt shows red on error, then returns to normal'"
Enter
Sleep 500ms

# 10. Final comprehensive view
Type "clear"
Enter
Sleep 500ms
Type "echo '=== Purity Enhanced Theme Features ==="
Enter
Type "echo '• Git status indicators: ✓ ✶ ✩ ⚑'"
Enter
Type "echo '• Execution time: shown for commands >5s'"
Enter  
Type "echo '• Error detection: red prompt on failure'"
Enter
Type "echo '• Clean, minimal design'"
Enter
Sleep 1s
Screenshot screenshot.png