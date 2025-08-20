#!/usr/bin/env zsh
# Mock async framework helpers for testing
# This mock implementation simulates zsh-async behavior for testing purposes

# Global variables to track mock state
typeset -gA MOCK_ASYNC_WORKERS        # Track active workers
typeset -gA MOCK_ASYNC_CALLBACKS      # Track registered callbacks
typeset -gA MOCK_ASYNC_WORKER_JOBS    # Track jobs per worker
typeset -g MOCK_ASYNC_INITIALIZED=0   # Track initialization status
typeset -ga MOCK_ASYNC_JOBS           # Track queued jobs

# Initialize async framework
# Usage: async_init
async_init() {
    MOCK_ASYNC_INITIALIZED=1
    return 0
}

# Start a new async worker
# Usage: async_start_worker <worker_name> [options]
async_start_worker() {
    local worker="$1"
    shift
    local options="$@"
    
    if [[ -z "$worker" ]]; then
        return 1
    fi
    
    MOCK_ASYNC_WORKERS[$worker]="$options"
    return 0
}

# Stop an async worker
# Usage: async_stop_worker <worker_name>
async_stop_worker() {
    local worker="$1"
    
    if [[ -z "$worker" ]]; then
        return 1
    fi
    
    # Clean up worker state
    unset "MOCK_ASYNC_WORKERS[$worker]"
    unset "MOCK_ASYNC_CALLBACKS[$worker]"
    
    # Clean up job tracking for this worker
    local job_key
    for job_key in ${(k)MOCK_ASYNC_WORKER_JOBS}; do
        if [[ "$job_key" == "${worker}:"* ]]; then
            unset "MOCK_ASYNC_WORKER_JOBS[$job_key]"
        fi
    done
    
    return 0
}

# Register a callback function for a worker
# Usage: async_register_callback <worker_name> <callback_function>
async_register_callback() {
    local worker="$1"
    local callback="$2"
    
    if [[ -z "$worker" || -z "$callback" ]]; then
        return 1
    fi
    
    MOCK_ASYNC_CALLBACKS[$worker]="$callback"
    return 0
}

# Unregister callback for a worker
# Usage: async_unregister_callback <worker_name>
async_unregister_callback() {
    local worker="$1"
    
    if [[ -z "$worker" ]]; then
        return 1
    fi
    
    unset "MOCK_ASYNC_CALLBACKS[$worker]"
    return 0
}

# Submit a job to an async worker
# Usage: async_job <worker_name> <function_name> [args...]
async_job() {
    local worker="$1"
    local job="$2"
    shift 2
    local args="$@"
    
    if [[ -z "$worker" || -z "$job" ]]; then
        return 1
    fi
    
    # Check if worker exists
    if [[ ! -v "MOCK_ASYNC_WORKERS[$worker]" ]]; then
        return 1
    fi
    
    # Track job for this worker
    local job_key="${worker}:${job}"
    MOCK_ASYNC_WORKER_JOBS[$job_key]="pending"
    
    # For testing, execute job synchronously and simulate callback
    local output
    local exit_code
    local exec_time="0.001"
    local start_time=$EPOCHSECONDS
    
    # Execute the job function if it exists, otherwise simulate output
    if (( $+functions[$job] )); then
        output=$($job "$@" 2>&1)
        exit_code=$?
    else
        # Simulate job execution for non-existent functions
        output="mock_job_output"
        exit_code=0
    fi
    
    # Calculate execution time
    if [[ -n "$start_time" ]]; then
        exec_time=$((EPOCHSECONDS - start_time))
        [[ $exec_time -eq 0 ]] && exec_time="0.001"
    fi
    
    # Mark job as completed
    MOCK_ASYNC_WORKER_JOBS[$job_key]="completed:$exit_code"
    
    # Trigger callback if registered
    if [[ -v "MOCK_ASYNC_CALLBACKS[$worker]" ]]; then
        local callback="${MOCK_ASYNC_CALLBACKS[$worker]}"
        if (( $+functions[$callback] )); then
            # Call callback with correct parameter order:
            # $1 = job_name, $2 = exit_code, $3 = output, $4 = exec_time
            $callback "$job" "$exit_code" "$output" "$exec_time"
        fi
    fi
    
    return 0
}

# Evaluate code in worker context
# Usage: async_worker_eval <worker_name> <code>
async_worker_eval() {
    local worker="$1"
    local code="$2"
    
    if [[ -z "$worker" ]]; then
        return 1
    fi
    
    # Check if worker exists
    if [[ ! -v "MOCK_ASYNC_WORKERS[$worker]" ]]; then
        return 1
    fi
    
    # For testing, we just return success since we can't actually
    # evaluate code in a separate worker context
    return 0
}

# Flush all jobs for a worker
# Usage: async_flush_jobs <worker_name>
async_flush_jobs() {
    local worker="$1"
    
    if [[ -z "$worker" ]]; then
        return 1
    fi
    
    # Check if worker exists
    if [[ ! -v "MOCK_ASYNC_WORKERS[$worker]" ]]; then
        return 1
    fi
    
    # Clear all jobs for this worker
    local job_key
    for job_key in ${(k)MOCK_ASYNC_WORKER_JOBS}; do
        if [[ "$job_key" == "${worker}:"* ]]; then
            unset "MOCK_ASYNC_WORKER_JOBS[$job_key]"
        fi
    done
    
    return 0
}

# Process async results (internal function)
async_process_results() {
    # This would normally process results from workers
    # For testing, this is handled by async_job directly
    return 0
}

# Mock async framework setup
mock_async_setup() {
    # Check if async_init function exists, if not, re-source this file
    if ! (( $+functions[async_init] )); then
        # Get the path to this file for re-sourcing
        local mock_async_file="${(%):-%x}"
        if [[ -f "$mock_async_file" ]]; then
            # Re-source the file to restore functions
            source "$mock_async_file" || {
                echo "Warning: Failed to re-source mock-async.zsh, using fallback" >&2
                # Fallback: define minimal async_init function
                async_init() {
                    MOCK_ASYNC_INITIALIZED=1
                    return 0
                }
            }
        else
            # Fallback: define minimal async_init function
            async_init() {
                MOCK_ASYNC_INITIALIZED=1
                return 0
            }
        fi
    fi
    
    # Ensure the arrays are initialized (in case they were cleaned up)
    typeset -gA MOCK_ASYNC_WORKERS
    typeset -gA MOCK_ASYNC_CALLBACKS  
    typeset -gA MOCK_ASYNC_WORKER_JOBS
    typeset -ga MOCK_ASYNC_JOBS
    
    # Set flag indicating async is available
    export MOCK_ASYNC_AVAILABLE=1
    
    # Initialize the async framework
    async_init
}

# Mock async worker function with controllable behavior
# Usage: mock_async_worker [behavior] [delay]
mock_async_worker() {
    local behavior="${1:-success}"
    local delay="${2:-0}"
    
    [[ $delay -gt 0 ]] && sleep "$delay"
    
    case "$behavior" in
        success)
            echo "mock_output"
            return 0
            ;;
        failure)
            echo "error_output" >&2
            return 1
            ;;
        timeout)
            sleep 100  # Simulate long-running task
            ;;
        *)
            echo "$behavior"
            return 0
            ;;
    esac
}

# Simulate async callback invocation manually
# This is useful for testing callback handling without running actual jobs
mock_async_callback() {
    local worker="$1"
    local exit_code="${2:-0}"
    local output="${3:-mock_output}"
    local exec_time="${4:-0.001}"
    local job="${5:-mock_job}"
    
    if [[ -v "MOCK_ASYNC_CALLBACKS[$worker]" ]]; then
        local callback="${MOCK_ASYNC_CALLBACKS[$worker]}"
        if (( $+functions[$callback] )); then
            # Call callback with correct parameter order:
            # $1 = job_name, $2 = exit_code, $3 = output, $4 = exec_time
            $callback "$job" "$exit_code" "$output" "$exec_time"
        fi
    fi
}

# Test helper: Check if async is properly initialized
mock_async_is_initialized() {
    [[ $MOCK_ASYNC_INITIALIZED -eq 1 ]]
}

# Test helper: Check if worker exists
mock_async_worker_exists() {
    local worker="$1"
    [[ -v "MOCK_ASYNC_WORKERS[$worker]" ]]
}

# Test helper: Get worker options
mock_async_worker_options() {
    local worker="$1"
    echo "${MOCK_ASYNC_WORKERS[$worker]}"
}

# Test helper: Get registered callback for worker
mock_async_worker_callback() {
    local worker="$1"
    echo "${MOCK_ASYNC_CALLBACKS[$worker]}"
}

# Get worker job status
# Usage: mock_async_worker_job_status <worker> <job>
mock_async_worker_job_status() {
    local worker="$1"
    local job="$2"
    local job_key="${worker}:${job}"
    
    echo "${MOCK_ASYNC_WORKER_JOBS[$job_key]:-not_found}"
}

# List all jobs for a worker
# Usage: mock_async_worker_jobs <worker>
mock_async_worker_jobs() {
    local worker="$1"
    local job_key
    
    for job_key in ${(k)MOCK_ASYNC_WORKER_JOBS}; do
        if [[ "$job_key" == "${worker}:"* ]]; then
            local job_name="${job_key#*:}"
            local job_status="${MOCK_ASYNC_WORKER_JOBS[$job_key]}"
            echo "$job_name:$job_status"
        fi
    done
}

# Check if async framework is available (for compatibility)
# Usage: async_available
async_available() {
    [[ "$MOCK_ASYNC_INITIALIZED" -eq 1 ]] && [[ -n "$MOCK_ASYNC_AVAILABLE" ]]
}

# Clean up mock async environment
mock_async_cleanup() {
    # Clear global variables
    unset MOCK_ASYNC_INITIALIZED 2>/dev/null || true
    unset MOCK_ASYNC_AVAILABLE 2>/dev/null || true
    unset MOCK_ASYNC_WORKERS 2>/dev/null || true
    unset MOCK_ASYNC_CALLBACKS 2>/dev/null || true
    unset MOCK_ASYNC_WORKER_JOBS 2>/dev/null || true
    unset MOCK_ASYNC_JOBS 2>/dev/null || true
    
    # Remove async functions
    unset -f async_init 2>/dev/null || true
    unset -f async_start_worker 2>/dev/null || true
    unset -f async_stop_worker 2>/dev/null || true
    unset -f async_job 2>/dev/null || true
    unset -f async_register_callback 2>/dev/null || true
    unset -f async_unregister_callback 2>/dev/null || true
    unset -f async_worker_eval 2>/dev/null || true
    unset -f async_flush_jobs 2>/dev/null || true
    unset -f async_process_results 2>/dev/null || true
    unset -f async_available 2>/dev/null || true
}

# Initialize arrays if not already set
typeset -gA MOCK_ASYNC_WORKERS
typeset -gA MOCK_ASYNC_CALLBACKS
typeset -gA MOCK_ASYNC_WORKER_JOBS
typeset -ga MOCK_ASYNC_JOBS