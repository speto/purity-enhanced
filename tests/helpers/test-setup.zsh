#!/usr/bin/env zsh
# Universal test setup that works in both Docker and local environments

# Robust repository root detection
find_repo_root() {
    local current_dir="${PWD}"
    
    # Method 1: Check if we're already in the repo root
    if [[ -f "$current_dir/purity-enhanced.zsh" ]]; then
        echo "$current_dir"
        return 0
    fi
    
    # Method 2: Use ZUNIT_TEST_ROOT if set
    if [[ -n "${ZUNIT_TEST_ROOT:-}" ]] && [[ -f "$ZUNIT_TEST_ROOT/purity-enhanced.zsh" ]]; then
        echo "$ZUNIT_TEST_ROOT"
        return 0
    fi
    
    # Method 3: Search upwards from current directory
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/purity-enhanced.zsh" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="${current_dir:h}"
    done
    
    # Method 4: Check common Docker paths
    for path in /workspace /app /src; do
        if [[ -f "$path/purity-enhanced.zsh" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Set up the test environment
setup_test_environment() {
    # Find and set repo root
    local repo_root
    if ! repo_root=$(find_repo_root); then
        echo "Error: Could not find repository root" >&2
        return 1
    fi
    
    # Export environment variables
    export ZUNIT_TEST_ROOT="$repo_root"
    export THEME_FILE="$repo_root/purity-enhanced.zsh"
    export PURITY_TEST_DIR="$repo_root/tests"
    export FPATH="$repo_root:$FPATH"
    export PATH="$repo_root:$PATH"
    
    # Change to repo root for consistent execution
    cd "$repo_root" || return 1
    
    # Source the theme file
    if [[ -f "$THEME_FILE" ]]; then
        setopt extended_glob null_glob prompt_subst
        source "$THEME_FILE" || {
            echo "Error: Failed to source theme file" >&2
            return 1
        }
    else
        echo "Error: Theme file not found at $THEME_FILE" >&2
        return 1
    fi
    
    # Load test helpers
    if [[ -f "$PURITY_TEST_DIR/helpers/load-helpers.zsh" ]]; then
        source "$PURITY_TEST_DIR/helpers/load-helpers.zsh" || {
            echo "Error: Failed to load test helpers" >&2
            return 1
        }
    else
        echo "Error: Test helpers not found" >&2
        return 1
    fi
    
    return 0
}

# Provide a simple interface for tests
load_test_environment() {
    if ! setup_test_environment; then
        echo "Failed to set up test environment" >&2
        return 1
    fi
}

# Export the main function
typeset -f load_test_environment > /dev/null