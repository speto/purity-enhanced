#!/usr/bin/env zsh
# zpty-based Test Helper for Integration Testing with ZLE and Async Support
#
# This helper provides functions for testing ZSH themes that require:
# - Interactive shells (ZLE enabled)
# - Async callback functionality (zsh-async)
# - Git operations and prompt rendering
#
# Based on the testing approach used by zsh-async itself.

# Load zpty module
zmodload zsh/zpty 2>/dev/null || {
    echo "ERROR: zpty module not available. Cannot run interactive tests." >&2
    return 1
}

# Global variables for test session management
declare -g -A ZPTY_TEST_SESSIONS
declare -g ZPTY_TEST_TIMEOUT=10
declare -g ZPTY_TEST_DEBUG=${ZPTY_TEST_DEBUG:-0}

# Debug logging function
zpty_debug() {
    [[ $ZPTY_TEST_DEBUG -eq 1 ]] && echo "ZPTY_DEBUG: $*" >&2
}

# Create a new interactive ZSH test session
# Usage: zpty_start_session <session_name> [init_commands...]
zpty_start_session() {
    local session_name="$1"
    shift
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    # Clean up any existing session with the same name
    zpty_cleanup_session "$session_name" 2>/dev/null
    
    zpty_debug "Starting interactive session: $session_name"
    
    # Start interactive zsh with proper options
    zpty -b "$session_name" zsh -i -o INTERACTIVE -o ZLE
    
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to start zpty session: $session_name" >&2
        return 1
    fi
    
    # Track the session
    ZPTY_TEST_SESSIONS[$session_name]=1
    
    # Wait for initial prompt and clear startup messages
    zpty_wait_for_prompt "$session_name"
    
    # Set up basic environment
    zpty_send_command "$session_name" "export TERM=xterm-256color"
    zpty_send_command "$session_name" "export LANG=C.UTF-8" 
    zpty_send_command "$session_name" "export LC_ALL=C.UTF-8"
    
    # Load zsh-async if available
    if [[ -f /usr/share/zsh/site-functions/async.zsh ]]; then
        zpty_send_command "$session_name" "source /usr/share/zsh/site-functions/async.zsh"
        zpty_debug "Loaded async.zsh in session $session_name"
    fi
    
    # Execute any initialization commands
    for cmd in "$@"; do
        zpty_send_command "$session_name" "$cmd"
    done
    
    zpty_debug "Session $session_name ready"
    return 0
}

# Send a command to a zpty session
# Usage: zpty_send_command <session_name> <command>
zpty_send_command() {
    local session_name="$1"
    local command="$2"
    
    if [[ -z "$session_name" || -z "$command" ]]; then
        echo "ERROR: Session name and command required" >&2
        return 1
    fi
    
    if [[ -z "${ZPTY_TEST_SESSIONS[$session_name]}" ]]; then
        echo "ERROR: Session $session_name not found" >&2
        return 1
    fi
    
    zpty_debug "Sending to $session_name: $command"
    zpty -w "$session_name" "$command"
    
    return 0
}

# Read output from a zpty session with timeout
# Usage: zpty_read_output <session_name> [timeout_seconds]
zpty_read_output() {
    local session_name="$1"
    local timeout="${2:-$ZPTY_TEST_TIMEOUT}"
    local output=""
    local partial_output
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    if [[ -z "${ZPTY_TEST_SESSIONS[$session_name]}" ]]; then
        echo "ERROR: Session $session_name not found" >&2
        return 1
    fi
    
    zpty_debug "Reading from $session_name with timeout $timeout"
    
    # Read with timeout
    if zpty -rt "$session_name" partial_output "$timeout"; then
        output="$partial_output"
        # Continue reading any additional output
        while zpty -rt "$session_name" partial_output 0.1; do
            output="$output$partial_output"
        done
        zpty_debug "Read ${#output} characters from $session_name"
        echo "$output"
        return 0
    else
        zpty_debug "Timeout or no output from $session_name"
        return 1
    fi
}

# Wait for a prompt to appear (indicating command completion)
# Usage: zpty_wait_for_prompt <session_name> [timeout_seconds]
zpty_wait_for_prompt() {
    local session_name="$1"
    local timeout="${2:-$ZPTY_TEST_TIMEOUT}"
    local output
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    zpty_debug "Waiting for prompt in $session_name"
    
    # Send a unique marker command and wait for it to complete
    local marker="__ZPTY_MARKER_$$_$(date +%s)__"
    zpty_send_command "$session_name" "echo '$marker'"
    
    # Read until we see the marker
    local attempts=0
    local max_attempts=$((timeout * 10)) # Check every 0.1 seconds
    
    while [[ $attempts -lt $max_attempts ]]; do
        if output=$(zpty_read_output "$session_name" 0.1); then
            if [[ "$output" == *"$marker"* ]]; then
                zpty_debug "Found prompt marker in $session_name"
                return 0
            fi
        fi
        ((attempts++))
        sleep 0.1
    done
    
    zpty_debug "Timeout waiting for prompt in $session_name"
    return 1
}

# Execute a command and wait for completion
# Usage: zpty_execute_and_wait <session_name> <command> [timeout_seconds]
zpty_execute_and_wait() {
    local session_name="$1"
    local command="$2"
    local timeout="${3:-$ZPTY_TEST_TIMEOUT}"
    
    if [[ -z "$session_name" || -z "$command" ]]; then
        echo "ERROR: Session name and command required" >&2
        return 1
    fi
    
    zpty_debug "Executing and waiting: $command"
    
    # Send command
    zpty_send_command "$session_name" "$command"
    
    # Wait for completion
    zpty_wait_for_prompt "$session_name" "$timeout"
}

# Load purity-enhanced theme in a test session
# Usage: zpty_load_theme <session_name>
zpty_load_theme() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    zpty_debug "Loading purity-enhanced theme in $session_name"
    
    # Ensure we have the theme file location
    local theme_file="${THEME_FILE:-${ZUNIT_TEST_ROOT:-/workspace}/purity-enhanced.zsh}"
    
    if [[ ! -f "$theme_file" ]]; then
        echo "ERROR: Theme file not found: $theme_file" >&2
        return 1
    fi
    
    # Load the theme
    zpty_execute_and_wait "$session_name" "source '$theme_file'"
    
    # Setup the theme
    zpty_execute_and_wait "$session_name" "prompt_purity_enhanced_setup"
    
    # Verify theme loaded
    local output
    zpty_send_command "$session_name" "type prompt_purity_enhanced_precmd"
    if output=$(zpty_read_output "$session_name"); then
        if [[ "$output" != *"function"* ]]; then
            echo "ERROR: Theme failed to load properly" >&2
            return 1
        fi
    else
        echo "ERROR: Could not verify theme loading" >&2
        return 1
    fi
    
    zpty_debug "Theme loaded successfully in $session_name"
    return 0
}

# Create a git repository in the test session
# Usage: zpty_setup_git_repo <session_name> <repo_path>
zpty_setup_git_repo() {
    local session_name="$1"
    local repo_path="$2"
    
    if [[ -z "$session_name" || -z "$repo_path" ]]; then
        echo "ERROR: Session name and repo path required" >&2
        return 1
    fi
    
    zpty_debug "Setting up git repo at $repo_path in $session_name"
    
    # Create directory and initialize git repo
    zpty_execute_and_wait "$session_name" "mkdir -p '$repo_path'"
    zpty_execute_and_wait "$session_name" "cd '$repo_path'"
    zpty_execute_and_wait "$session_name" "git init --quiet"
    zpty_execute_and_wait "$session_name" "git config user.name 'Test User'"
    zpty_execute_and_wait "$session_name" "git config user.email 'test@example.com'"
    
    # Create initial commit
    zpty_execute_and_wait "$session_name" "echo 'Initial content' > README.md"
    zpty_execute_and_wait "$session_name" "git add README.md"
    zpty_execute_and_wait "$session_name" "git commit -m 'Initial commit' --quiet"
    
    zpty_debug "Git repo setup complete in $session_name"
    return 0
}

# Test async functionality by triggering precmd and checking for async operations
# Usage: zpty_test_async_operations <session_name> [timeout_seconds]
zpty_test_async_operations() {
    local session_name="$1"
    local timeout="${2:-5}"
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    zpty_debug "Testing async operations in $session_name"
    
    # Trigger precmd which should start async operations
    zpty_execute_and_wait "$session_name" "prompt_purity_enhanced_precmd"
    
    # Give async operations time to complete
    zpty_debug "Waiting ${timeout}s for async operations to complete"
    sleep "$timeout"
    
    # Check if VCS info was populated by async callbacks
    zpty_send_command "$session_name" "echo 'VCS_INFO:' \${(kv)prompt_purity_enhanced_vcs_info}"
    local output
    if output=$(zpty_read_output "$session_name"); then
        echo "$output"
        if [[ "$output" == *"VCS_INFO:"* ]]; then
            zpty_debug "VCS info found in async operations"
            return 0
        fi
    fi
    
    zpty_debug "No VCS info found - async operations may not have completed"
    return 1
}

# Check if ZLE is active in a session
# Usage: zpty_check_zle <session_name>
zpty_check_zle() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    zpty_send_command "$session_name" "[[ -o zle ]] && echo 'ZLE:ACTIVE' || echo 'ZLE:INACTIVE'"
    local output
    if output=$(zpty_read_output "$session_name"); then
        if [[ "$output" == *"ZLE:ACTIVE"* ]]; then
            zpty_debug "ZLE is active in $session_name"
            return 0
        else
            zpty_debug "ZLE is not active in $session_name"
            return 1
        fi
    fi
    
    echo "ERROR: Could not check ZLE status" >&2
    return 1
}

# Check if async functions are available in a session
# Usage: zpty_check_async <session_name>
zpty_check_async() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    zpty_send_command "$session_name" "[[ \$+functions[async_start_worker] -eq 1 ]] && echo 'ASYNC:AVAILABLE' || echo 'ASYNC:UNAVAILABLE'"
    local output
    if output=$(zpty_read_output "$session_name"); then
        if [[ "$output" == *"ASYNC:AVAILABLE"* ]]; then
            zpty_debug "Async is available in $session_name"
            return 0
        else
            zpty_debug "Async is not available in $session_name"
            return 1
        fi
    fi
    
    echo "ERROR: Could not check async availability" >&2
    return 1
}

# Clean up a zpty session
# Usage: zpty_cleanup_session <session_name>
zpty_cleanup_session() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "ERROR: Session name required" >&2
        return 1
    fi
    
    if [[ -n "${ZPTY_TEST_SESSIONS[$session_name]}" ]]; then
        zpty_debug "Cleaning up session: $session_name"
        zpty -d "$session_name" 2>/dev/null || true
        unset "ZPTY_TEST_SESSIONS[$session_name]"
    fi
}

# Clean up all test sessions
# Usage: zpty_cleanup_all_sessions
zpty_cleanup_all_sessions() {
    zpty_debug "Cleaning up all test sessions"
    for session_name in "${(@k)ZPTY_TEST_SESSIONS}"; do
        zpty_cleanup_session "$session_name"
    done
}

# Validate that zpty testing environment is ready
# Usage: zpty_validate_environment
zpty_validate_environment() {
    # Check if zpty module is available
    if ! zmodload -e zsh/zpty; then
        echo "ERROR: zpty module not loaded" >&2
        return 1
    fi
    
    # Check if async is available
    if [[ ! -f /usr/share/zsh/site-functions/async.zsh ]]; then
        echo "WARNING: async.zsh not found at expected location" >&2
        echo "Async tests may fail" >&2
    fi
    
    # Check if theme file exists
    local theme_file="${THEME_FILE:-${ZUNIT_TEST_ROOT:-/workspace}/purity-enhanced.zsh}"
    if [[ ! -f "$theme_file" ]]; then
        echo "ERROR: Theme file not found: $theme_file" >&2
        return 1
    fi
    
    zpty_debug "Environment validation passed"
    return 0
}

# Trap to clean up sessions on exit
cleanup_on_exit() {
    zpty_cleanup_all_sessions
}
trap cleanup_on_exit EXIT