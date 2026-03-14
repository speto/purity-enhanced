#!/usr/bin/env zsh
# Interactive Test Helpers for ZSH Prompt Testing
#
# This module provides helper functions for running tests in interactive
# environments with proper PTY support for async/ZLE functionality.

# Set safer defaults
setopt ERR_EXIT
setopt NO_UNSET

# Get the directory containing this script
local helpers_dir="${${(%):-%x}:A:h}"

# Function to run a test script in interactive PTY environment
# Usage: run_interactive_test 'test_script_content' [timeout_seconds]
run_interactive_test() {
    local test_script="$1"
    local timeout="${2:-10}"  # Default 10 second timeout
    local wrapper="$helpers_dir/interactive-wrapper.sh"
    
    # Validate inputs
    if [[ -z "$test_script" ]]; then
        echo "Error: run_interactive_test requires test script content" >&2
        return 1
    fi
    
    if [[ ! -x "$wrapper" ]]; then
        echo "Error: Interactive wrapper not found or not executable: $wrapper" >&2
        return 1
    fi
    
    # Create temporary script file
    local test_file=$(mktemp "${TMPDIR:-/tmp}/interactive_test_XXXXXX.zsh")
    
    # Write test script with proper error handling
    cat > "$test_file" << 'SCRIPT_END'
#!/usr/bin/env zsh
# Generated interactive test script
set -e  # Exit on error
set -u  # Error on undefined variables

# Enable interactive mode options
setopt INTERACTIVE
setopt ZLE

# Set up environment variables for test
export TERM=${TERM:-xterm-256color}
export COLUMNS=${COLUMNS:-80}
export LINES=${LINES:-24}

# Make current environment available
export THEME_FILE="${THEME_FILE:-}"
export INTEGRATION_TEST_DIR="${INTEGRATION_TEST_DIR:-}"
export PURITY_TEST_DIR="${PURITY_TEST_DIR:-}"

# Change to test directory if specified
if [[ -n "${INTEGRATION_TEST_DIR:-}" && -d "$INTEGRATION_TEST_DIR" ]]; then
    cd "$INTEGRATION_TEST_DIR"
fi

SCRIPT_END

    # Append the actual test script
    echo "$test_script" >> "$test_file"
    
    # Make it executable
    chmod +x "$test_file"
    
    # Run with timeout to prevent hanging tests
    local result=0
    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout" "$wrapper" zsh -i "$test_file" || result=$?
    else
        # Fallback if timeout command not available
        "$wrapper" zsh -i "$test_file" || result=$?
    fi
    
    # Clean up
    rm -f "$test_file"
    
    return $result
}

# Function to run a simple interactive command and capture output
# Usage: run_interactive_command 'command' [timeout_seconds]
run_interactive_command() {
    local command="$1"
    local timeout="${2:-5}"
    
    run_interactive_test "
        # Run the command and capture result
        result=\$(eval '$command' 2>&1) || exit \$?
        echo \"\$result\"
    " "$timeout"
}

# Function to test if async functionality is working
# Usage: test_async_functionality [timeout_seconds]
test_async_functionality() {
    local timeout="${2:-5}"
    
    run_interactive_test '
        # Load async if available
        if [[ -f /usr/share/zsh/site-functions/async.zsh ]]; then
            source /usr/share/zsh/site-functions/async.zsh
        else
            echo "async.zsh not found" >&2
            exit 1
        fi
        
        # Initialize async
        if ! async_init; then
            echo "async_init failed" >&2
            exit 1
        fi
        
        # Test basic async functionality
        local callback_fired=0
        test_callback() { callback_fired=1; }
        
        async_start_worker test_worker -n
        async_register_callback test_worker test_callback
        async_job test_worker "echo test_output"
        
        # Wait for callback
        local waited=0
        while (( !callback_fired && waited < 20 )); do
            sleep 0.1
            (( waited++ ))
        done
        
        async_stop_worker test_worker
        
        if (( callback_fired )); then
            echo "Async functionality working"
            exit 0
        else
            echo "Async callback did not fire after ${waited} iterations" >&2
            exit 1
        fi
    ' "$timeout"
}

# Function to validate interactive environment
# Usage: validate_interactive_environment
validate_interactive_environment() {
    run_interactive_test '
        # Check if we are in interactive mode
        if [[ ! -o interactive ]]; then
            echo "Not in interactive mode" >&2
            exit 1
        fi
        
        # Check if ZLE is available
        if [[ ! -o zle ]]; then
            echo "ZLE not available" >&2
            exit 1
        fi
        
        # Check basic ZLE functions
        if ! (( $+functions[zle] )); then
            echo "zle function not available" >&2
            exit 1
        fi
        
        echo "Interactive environment validated"
    '
}

# Export functions for use in test files
# Functions are automatically available in zsh when sourced