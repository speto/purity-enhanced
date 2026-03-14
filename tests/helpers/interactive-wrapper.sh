#!/bin/bash
# Interactive Test Wrapper
# 
# This script ensures tests run in an interactive PTY environment,
# enabling proper async/ZLE functionality for prompt testing.
#
# Usage: interactive-wrapper.sh <command> [args...]

set -e

# Function to check if script command supports required flags
check_script_compatibility() {
    # Test if script supports -q flag (most do)
    if script -q /dev/null echo "test" >/dev/null 2>&1; then
        return 0
    fi
    
    # Fallback: basic script without -q
    return 1
}

# Function to run with PTY using script command
run_with_pty() {
    local cmd="$*"
    
    if check_script_compatibility; then
        # Modern script with quiet flag
        script -qec "$cmd" /dev/null
    else
        # Fallback for older script versions
        # Redirect start/end messages to stderr, capture only command output
        script -c "$cmd" /dev/null 2>/dev/null || {
            # If that fails, try without -c flag
            echo "$cmd" | script /dev/null 2>/dev/null
        }
    fi
}

# Check if we're already in an interactive terminal
if [ -t 0 ] && [ -t 1 ] && [ -n "${PS1:-}" ]; then
    # Already in interactive environment, run directly
    exec "$@"
else
    # Not interactive, wrap in PTY
    run_with_pty "$@"
fi