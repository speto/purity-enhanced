#!/usr/bin/env zsh
# Load all test helpers

# Robust helper directory detection with multiple fallback mechanisms
detect_helpers_dir() {
    local helpers_dir
    
    # Method 1: Use $0 parameter expansion (works when script is executed directly)
    if [[ -n "${0:-}" && "$0" != "zsh" && "$0" != "-zsh" ]]; then
        helpers_dir="${0:A:h}"
        if [[ -f "$helpers_dir/mock-git.zsh" ]]; then
            echo "$helpers_dir"
            return 0
        fi
    fi
    
    # Method 2: Use funcstack/functrace for sourced scripts
    if [[ -n "${funcstack[1]:-}" ]]; then
        helpers_dir="${funcstack[1]:A:h}"
        if [[ -f "$helpers_dir/mock-git.zsh" ]]; then
            echo "$helpers_dir"
            return 0
        fi
    fi
    
    # Method 3: Try functrace (bash-style, some zsh configs)
    if [[ -n "${functrace[1]:-}" ]]; then
        helpers_dir="${functrace[1]%:*}"
        helpers_dir="${helpers_dir:A:h}"
        if [[ -f "$helpers_dir/mock-git.zsh" ]]; then
            echo "$helpers_dir"
            return 0
        fi
    fi
    
    # Method 4: Search relative to current working directory
    local search_paths=(
        "tests/helpers"           # From project root
        "helpers"                 # From tests directory
        "./tests/helpers"         # Explicit relative path
        "../helpers"              # From test subdirectory
        "."                       # Current directory
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path/mock-git.zsh" ]]; then
            echo "${path:A}"
            return 0
        fi
    done
    
    # Method 5: Find helpers directory in project structure
    local current_dir="$PWD"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/tests/helpers/mock-git.zsh" ]]; then
            echo "$current_dir/tests/helpers"
            return 0
        fi
        current_dir="${current_dir:h}"
    done
    
    # Method 6: Look for purity-enhanced.zsh to identify project root
    current_dir="$PWD"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/purity-enhanced.zsh" ]]; then
            if [[ -f "$current_dir/tests/helpers/mock-git.zsh" ]]; then
                echo "$current_dir/tests/helpers"
                return 0
            fi
        fi
        current_dir="${current_dir:h}"
    done
    
    # If all methods fail, return empty and let the sourcing fail gracefully
    return 1
}

# Get the helpers directory using robust detection
HELPERS_DIR="$(detect_helpers_dir)"

# Debug information (only if HELPERS_DEBUG is set)
if [[ -n "${HELPERS_DEBUG:-}" ]]; then
    echo "Debug: Helper loading information:" >&2
    echo "  PWD: $PWD" >&2
    echo "  \$0: ${0:-unset}" >&2
    echo "  funcstack[1]: ${funcstack[1]:-unset}" >&2
    echo "  Detected HELPERS_DIR: ${HELPERS_DIR:-failed}" >&2
fi

# Validate that we found the helpers directory
if [[ -z "$HELPERS_DIR" ]]; then
    echo "Error: Could not locate test helpers directory" >&2
    echo "Searched from: $PWD" >&2
    echo "Script location: ${0:-unknown}" >&2
    echo "Tip: Set HELPERS_DEBUG=1 for more detailed information" >&2
    return 1 2>/dev/null || exit 1
fi

# Source all helper modules with error handling
load_helper() {
    local helper_file="$1"
    if [[ -f "$HELPERS_DIR/$helper_file" ]]; then
        source "$HELPERS_DIR/$helper_file" || {
            echo "Error: Failed to source $helper_file" >&2
            return 1
        }
    else
        echo "Warning: Helper file $helper_file not found in $HELPERS_DIR" >&2
        return 1
    fi
}

# Load each helper module
load_helper "mock-git.zsh" || return 1
load_helper "mock-async.zsh" || return 1
load_helper "mock-contexts.zsh" || return 1
load_helper "mock-performance.zsh" || return 1

# Clean up helper functions (they're no longer needed)
unfunction detect_helpers_dir load_helper 2>/dev/null

# Debug success message
if [[ -n "${HELPERS_DEBUG:-}" ]]; then
    echo "Debug: Successfully loaded all test helpers from $HELPERS_DIR" >&2
fi

# Global test setup function
test_setup_with_mocks() {
    # Enable all mocks by default
    mock_async_setup
    mock_memory_setup
    mock_performance_timing
    mock_timeout_setup
    mock_network_setup
    mock_benchmark_setup
}

# Global test cleanup function
test_cleanup_mocks() {
    # Clean up all mocks
    mock_async_cleanup
    mock_contexts_cleanup
    mock_performance_cleanup
    
    # Clean up any temporary git repos
    for repo in /tmp/test-repo-*; do
        [[ -d "$repo" ]] && rm -rf "$repo"
    done
}

# Export setup and cleanup functions
# Functions are automatically available in zsh