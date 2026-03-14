#!/usr/bin/env zsh
# Single source of truth for ensuring real zsh-async is available
# Used by integration tests that need real async functionality

# Function to ensure real async is loaded and initialized
ensure_real_async() {
    # Check if async is already loaded and initialized
    if (( $+functions[async_start_worker] )) && (( ${ASYNC_INIT_DONE:-0} )); then
        return 0
    fi
    
    # Try to load zsh-async from standard Docker test location
    if [[ -f /usr/share/zsh/site-functions/async.zsh ]]; then
        source /usr/share/zsh/site-functions/async.zsh || {
            echo "ERROR: Failed to source /usr/share/zsh/site-functions/async.zsh" >&2
            return 1
        }
    else
        echo "ERROR: Real zsh-async not found" >&2
        echo "Expected location: /usr/share/zsh/site-functions/async.zsh" >&2
        echo "This indicates a test environment configuration issue" >&2
        return 1
    fi
    
    # Initialize async framework
    if ! async_init; then
        echo "ERROR: async_init failed" >&2
        return 1
    fi
    
    # Verify initialization succeeded
    if ! (( $+functions[async_start_worker] )); then
        echo "ERROR: async_start_worker function not available after init" >&2
        return 1
    fi
    
    return 0
}

# Function is available when sourced - no export needed in ZSH