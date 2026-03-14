#!/usr/bin/env zsh

# Purity Enhanced Theme Showcase
# Automated demo script that showcases all theme features

set -e

# Configuration
DEMO_ROOT="/tmp/purity-demo"
SLEEP_SHORT=1
SLEEP_MEDIUM=2
SLEEP_LONG=3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo_step() {
    echo "${CYAN}▶ $1${NC}"
}

echo_feature() {
    echo "${GREEN}✨ $1${NC}"
}

# Initialize demo environment
setup_environment() {
    echo_step "Setting up demo environment..."
    
    # Clean and create demo root
    rm -rf "$DEMO_ROOT"
    mkdir -p "$DEMO_ROOT"
    cd "$DEMO_ROOT"
    
    # Configure git for demo
    git config --global user.email "demo@purity-enhanced.dev"
    git config --global user.name "Demo User"
    git config --global init.defaultBranch main
}

# Showcase basic prompt features
demo_basic_features() {
    echo_feature "Basic Prompt Features"
    
    # Clean directory
    mkdir -p clean-dir && cd clean-dir
    sleep $SLEEP_SHORT
    
    # Show directory navigation
    echo_step "Directory navigation"
    pwd
    sleep $SLEEP_SHORT
    
    # Show command execution time (simulate long command)
    echo_step "Command execution time (>5 seconds)"
    echo "Simulating long-running command..."
    sleep 6
    sleep $SLEEP_SHORT
    
    # Show error state
    echo_step "Error state (red prompt)"
    false || true  # Intentional failure
    sleep $SLEEP_MEDIUM
    
    # Reset with successful command
    echo "Success - prompt should be normal color"
    sleep $SLEEP_SHORT
    
    cd "$DEMO_ROOT"
}

# Showcase git status indicators
demo_git_features() {
    echo_feature "Git Status Indicators"
    
    # Create git repository
    mkdir -p git-demo && cd git-demo
    git init
    echo_step "Clean git repository"
    sleep $SLEEP_MEDIUM
    
    # Untracked files
    echo "New file" > new-file.txt
    echo_step "Untracked files (✩)"
    sleep $SLEEP_MEDIUM
    
    # Staged changes
    git add new-file.txt
    echo_step "Staged changes (✓)"
    sleep $SLEEP_MEDIUM
    
    # Initial commit
    git commit -m "Initial commit"
    echo_step "Clean after commit"
    sleep $SLEEP_SHORT
    
    # Modified files
    echo "Modified content" >> new-file.txt
    echo_step "Modified files (✶)"
    sleep $SLEEP_MEDIUM
    
    # Mixed states
    echo "Another file" > another.txt
    git add new-file.txt
    echo_step "Mixed state: staged (✓) + untracked (✩)"
    sleep $SLEEP_MEDIUM
    
    # Deleted files
    rm another.txt
    git add another.txt
    echo "Deleted content" > deleted.txt
    git add deleted.txt
    git commit -m "Add files"
    rm deleted.txt
    echo_step "Deleted files (✗)"
    sleep $SLEEP_MEDIUM
    
    # Stashed changes
    git stash
    echo_step "Stashed changes (⚑)"
    sleep $SLEEP_MEDIUM
    
    cd "$DEMO_ROOT"
}

# Showcase git remote status
demo_git_remote() {
    echo_feature "Git Remote Status"
    
    # Create bare repository to simulate remote
    mkdir -p remote.git && cd remote.git
    git init --bare
    
    cd "$DEMO_ROOT"
    git clone remote.git local-clone
    cd local-clone
    
    # Create commits
    echo "Initial content" > file.txt
    git add file.txt
    git commit -m "Initial commit"
    git push origin main
    
    echo_step "Clean with remote"
    sleep $SLEEP_SHORT
    
    # Ahead of remote
    echo "New content" >> file.txt
    git add file.txt
    git commit -m "New commit"
    echo_step "Ahead of remote (↑1)"
    sleep $SLEEP_MEDIUM
    
    # Push and create behind scenario
    git push origin main
    
    # Simulate another developer's commit
    cd "$DEMO_ROOT"
    git clone remote.git another-clone
    cd another-clone
    echo "Remote content" > remote-file.txt
    git add remote-file.txt
    git commit -m "Remote commit"
    git push origin main
    
    # Now local-clone is behind
    cd "$DEMO_ROOT/local-clone"
    git fetch origin
    echo_step "Behind remote (↓1)"
    sleep $SLEEP_MEDIUM
    
    cd "$DEMO_ROOT"
}

# Showcase development contexts
demo_development_contexts() {
    echo_feature "Development Context Indicators"
    
    # Python context
    mkdir -p python-project && cd python-project
    cat > pyproject.toml << 'EOF'
[project]
name = "demo-project"
version = "1.0.0"
dependencies = ["requests"]
EOF
    echo_step "Python project context"
    sleep $SLEEP_MEDIUM
    
    # Node.js context
    cd "$DEMO_ROOT"
    mkdir -p nodejs-project && cd nodejs-project
    cat > package.json << 'EOF'
{
  "name": "demo-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
    echo_step "Node.js project context (⬢)"
    sleep $SLEEP_MEDIUM
    
    # Go context
    cd "$DEMO_ROOT"
    mkdir -p go-project && cd go-project
    cat > go.mod << 'EOF'
module demo

go 1.21

require github.com/gin-gonic/gin v1.9.1
EOF
    echo_step "Go project context (🐹)"
    sleep $SLEEP_MEDIUM
    
    # Docker context
    cd "$DEMO_ROOT"
    mkdir -p docker-project && cd docker-project
    cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: demo
EOF
    echo_step "Docker Compose project (🐳)"
    sleep $SLEEP_MEDIUM
    
    cd "$DEMO_ROOT"
}

# Simulate background jobs
demo_background_jobs() {
    echo_feature "Background Jobs Indicator"
    
    echo_step "No background jobs"
    sleep $SLEEP_SHORT
    
    echo_step "Starting background jobs..."
    sleep 30 &  # Background job 1
    sleep 30 &  # Background job 2
    sleep $SLEEP_SHORT
    
    echo_step "Background jobs indicator ([✦2])"
    sleep $SLEEP_MEDIUM
    
    # Kill background jobs
    killall sleep 2>/dev/null || true
}

# Main demo sequence
main() {
    setup_environment
    
    echo "${YELLOW}"
    echo "╔══════════════════════════════════════════╗"
    echo "║        Purity Enhanced Theme Demo        ║"
    echo "║                                          ║"
    echo "║  Showcasing all features automatically   ║"
    echo "╚══════════════════════════════════════════╝"
    echo "${NC}"
    sleep $SLEEP_LONG
    
    demo_basic_features
    sleep $SLEEP_MEDIUM
    
    demo_git_features
    sleep $SLEEP_MEDIUM
    
    demo_git_remote
    sleep $SLEEP_MEDIUM
    
    demo_development_contexts
    sleep $SLEEP_MEDIUM
    
    demo_background_jobs
    sleep $SLEEP_MEDIUM
    
    echo "${GREEN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║            Demo Complete!                ║"
    echo "║                                          ║"
    echo "║   All Purity Enhanced features shown     ║"
    echo "╚══════════════════════════════════════════╝"
    echo "${NC}"
    
    # Return to demo root
    cd "$DEMO_ROOT"
}

# Execute main if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi