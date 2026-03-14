# VHS Configuration for Purity Enhanced Theme Demo
# Generates high-quality GIF and video demonstrations

# Output settings
Output demo.gif
Output demo.mp4

# Terminal settings  
Set Shell "zsh"
Set Theme "Dracula"
Set FontFamily "JetBrains Mono"
Set FontSize 14
Set Width 1200
Set Height 800
Set TypingSpeed 60ms
Set Padding 20

# Initialize shell and load theme
Sleep 500ms
Type "source /usr/share/zsh/site-functions/async.zsh"
Enter
Sleep 200ms
Type "source /etc/zsh/purity-enhanced.zsh"
Enter  
Sleep 200ms
Type "prompt_purity_enhanced_setup"
Enter
Sleep 500ms

# Start recording with clean screen
Type "clear"
Enter
Sleep 1s
Type "echo"
Space
Type '"╔══════════════════════════════════════════╗"'
Enter
Type "echo"
Space  
Type '"║        Purity Enhanced Theme Demo        ║"'
Enter
Type "echo"
Space
Type '"║                                          ║"'
Enter
Type "echo"
Space
Type '"║  Beautiful, fast ZSH prompt with git    ║"'
Enter
Type "echo"
Space
Type '"╚══════════════════════════════════════════╝"'
Enter
Sleep 1s

# Start the automated showcase
Type "cd /tmp && mkdir purity-showcase && cd purity-showcase"
Enter
Sleep 1s

# Basic directory navigation
Type "pwd"
Enter 
Sleep 1s
Type "echo 'Basic prompt - clean directory'"
Enter
Sleep 1s

# Initialize git repository
Type "git init"
Enter
Sleep 1s
Type "echo 'Git initialized - clean repository'"
Enter
Sleep 1s

# Show untracked files
Type "echo 'New feature' > feature.txt"
Enter
Sleep 1s
Type "echo 'Untracked files indicator (✩)'"
Enter
Sleep 1s

# Show staged changes
Type "git add feature.txt"
Enter
Sleep 1s
Type "echo 'Staged changes indicator (✓)'"
Enter
Sleep 1s

# Commit and show modified
Type "git commit -m 'Add feature'"
Enter
Sleep 1s
Type "echo 'Modified content' >> feature.txt"
Enter
Sleep 1s
Type "echo 'Modified files indicator (✶)'"
Enter
Sleep 1s

# Show mixed state
Type "echo 'Another file' > another.txt"
Enter
Type "git add feature.txt"
Enter
Sleep 1s
Type "echo 'Mixed state: staged + untracked'"
Enter
Sleep 1s

# Show execution time
Type "echo 'Command execution time demo...'"
Enter
Type "sleep 6"
Enter
Sleep 7s
Type "echo 'Execution time shown (> 5 seconds)'"
Enter
Sleep 1s

# Show error state
Type "echo 'Error state demo...'"
Enter
Type "nonexistent-command"
Enter
Sleep 1s
Type "echo 'Prompt turns red on error'"
Enter
Sleep 1s

# Show success state
Type "echo 'Success - back to normal'"
Enter
Sleep 1s

# Show language contexts
Type "echo 'Language context demos...'"
Enter
Sleep 1s

# Python context
Type "echo '[project]' > pyproject.toml"
Enter
Type "echo name = demo >> pyproject.toml"
Enter
Sleep 1s
Type "echo 'Python project detected'"
Enter
Sleep 1s

# Node.js context
Type "echo {name: demo} > package.json"
Enter
Sleep 1s
Type "echo 'Node.js project detected (⬢)'"
Enter
Sleep 1s

# Docker context  
Type "echo version: 3 > docker-compose.yml"
Enter
Type "echo 'services:' >> docker-compose.yml"
Enter
Type "echo '  web:' >> docker-compose.yml"
Enter
Type "echo '    image: nginx' >> docker-compose.yml"
Enter
Sleep 1s
Type "echo 'Docker Compose detected (🐳)'"
Enter
Sleep 1s

# Show git stash
Type "echo 'More changes' >> feature.txt"
Enter
Type "git stash"
Enter
Sleep 1s
Type "echo 'Stashed changes indicator (⚑)'"
Enter
Sleep 1s

# Final message
Sleep 1s
Type "clear"
Enter
Type "echo"
Space
Type '"╔══════════════════════════════════════════╗"'
Enter
Type "echo"
Space
Type '"║           Demo Complete!                 ║"'
Enter
Type "echo"
Space
Type '"║                                          ║"'
Enter
Type "echo"
Space  
Type '"║  Purity Enhanced - Beautiful ZSH Theme  ║"'
Enter
Type "echo"
Space
Type '"║                                          ║"'
Enter
Type "echo"
Space
Type '"║  github.com/speto/purity-enhanced        ║"'
Enter  
Type "echo"
Space
Type '"╚══════════════════════════════════════════╝"'
Enter

Sleep 2s