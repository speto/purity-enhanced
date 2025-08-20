#!/usr/bin/env zsh
# Mock git repository helpers for testing

# Create a mock git repository with various states
mock_git_repo_create() {
    local repo_dir="${1:-/tmp/test-repo-$$}"
    
    mkdir -p "$repo_dir"
    cd "$repo_dir"
    
    # Initialize git repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "initial" > file.txt
    git add file.txt
    git commit -m "Initial commit" --quiet
    
    echo "$repo_dir"
}

# Set up a repo in rebase state
mock_git_repo_rebase() {
    local repo_dir="$1"
    cd "$repo_dir"
    
    # Create a branch and commits for rebase
    git checkout -b feature --quiet
    echo "feature" >> file.txt
    git add file.txt
    git commit -m "Feature commit" --quiet
    
    # Create rebase state files
    mkdir -p .git/rebase-merge
    echo "pick 123456 Feature commit" > .git/rebase-merge/git-rebase-todo
    
    echo "$repo_dir"
}

# Set up a repo in merge state
mock_git_repo_merge() {
    local repo_dir="$1"
    cd "$repo_dir"
    
    # Create merge state files
    mkdir -p .git
    touch .git/MERGE_HEAD
    echo "Merging branch 'feature'" > .git/MERGE_MSG
    
    echo "$repo_dir"
}

# Set up a repo with uncommitted changes
mock_git_repo_dirty() {
    local repo_dir="$1"
    cd "$repo_dir"
    
    # Staged changes
    echo "staged" > staged.txt
    git add staged.txt
    
    # Unstaged changes
    echo "modified" >> file.txt
    
    # Untracked files
    echo "untracked" > untracked.txt
    
    echo "$repo_dir"
}

# Set up a repo with remotes
mock_git_repo_with_remotes() {
    local repo_dir="$1"
    cd "$repo_dir"
    
    # Add fake remote
    git remote add origin https://github.com/test/repo.git
    
    # Create local ahead/behind simulation
    echo "ahead" >> file.txt
    git add file.txt
    git commit -m "Local commit" --quiet
    
    # Simulate remote tracking branch
    git update-ref refs/remotes/origin/main HEAD~1
    git branch --set-upstream-to=origin/main main 2>/dev/null || true
    
    echo "$repo_dir"
}

# Clean up mock repo
mock_git_repo_cleanup() {
    local repo_dir="$1"
    [[ -d "$repo_dir" ]] && rm -rf "$repo_dir"
}

# Functions are automatically available in zsh, no need for export -f