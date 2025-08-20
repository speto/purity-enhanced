#!/usr/bin/env zsh
# Mock performance and memory testing helpers

# Improved timing function for reliable benchmarks
get_reliable_time_ms() {
    # Use multiple timing methods for better reliability
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    elif [[ "$(uname)" == "Linux" ]] && date +%s%3N >/dev/null 2>&1; then
        # GNU date with millisecond precision
        date +%s%3N
    else
        # Fallback to second precision
        echo "$(($(date +%s) * 1000))"
    fi
}

# Helper for silent execution in tests
run_silently() {
    "$@" >/dev/null 2>&1
}

# Mock memory usage monitoring
mock_memory_setup() {
    # Mock memory usage function
    get_memory_usage() {
        local process="${1:-$$}"
        echo "1024"  # Return mock memory usage in KB
    }
    
    # Mock memory tracking
    track_memory_usage() {
        local start_mem=$(get_memory_usage)
        "$@"
        local end_mem=$(get_memory_usage)
        echo $((end_mem - start_mem))
    }
    
    # Functions are automatically available in zsh
}

# Mock performance timing
mock_performance_timing() {
    # High precision timer mock
    get_time_ms() {
        # Use the reliable timing function
        get_reliable_time_ms
    }
    
    # Measure execution time
    measure_time() {
        local start=$(get_time_ms)
        "$@"
        local end=$(get_time_ms)
        echo $((end - start))
    }
    
    # Functions are automatically available in zsh
}

# Mock memory leak detection
mock_memory_leak_detector() {
    detect_memory_leak() {
        local iterations="${1:-10}"
        local command="$2"
        local threshold="${3:-100}"  # KB threshold
        
        local initial_mem=$(get_memory_usage)
        
        for ((i=0; i<iterations; i++)); do
            eval "$command"
        done
        
        local final_mem=$(get_memory_usage)
        local diff=$((final_mem - initial_mem))
        
        if [[ $diff -gt $threshold ]]; then
            echo "LEAK_DETECTED: ${diff}KB increase"
            return 1
        else
            echo "NO_LEAK"
            return 0
        fi
    }
    
    # Function is automatically available in zsh
}

# Mock concurrent execution testing
mock_concurrent_execution() {
    # Run commands concurrently and measure
    run_concurrent() {
        local num_workers="${1:-5}"
        local command="$2"
        
        local pids=()
        
        for ((i=0; i<num_workers; i++)); do
            eval "$command" &
            pids+=($!)
        done
        
        # Wait for all to complete
        for pid in ${pids[@]}; do
            wait $pid
        done
        
        echo "CONCURRENT_COMPLETE: $num_workers workers"
    }
    
    # Function is automatically available in zsh
}

# Mock timeout simulation
mock_timeout_setup() {
    # Execute with timeout
    with_timeout() {
        local timeout="${1:-5}"
        shift
        
        # Use timeout command if available, otherwise mock
        if command -v timeout >/dev/null 2>&1; then
            timeout "$timeout" "$@"
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                echo "TIMEOUT_EXCEEDED"
            fi
            return $exit_code
        else
            # Simple mock implementation
            "$@" &
            local pid=$!
            
            (sleep "$timeout" && kill -TERM $pid 2>/dev/null) &
            local timer_pid=$!
            
            if wait $pid 2>/dev/null; then
                kill $timer_pid 2>/dev/null
                return 0
            else
                echo "TIMEOUT_EXCEEDED"
                return 124
            fi
        fi
    }
    
    # Function is automatically available in zsh
}

# Mock network operations
mock_network_setup() {
    # Simulate network delay
    with_network_delay() {
        local delay="${1:-0.5}"
        shift
        sleep "$delay"
        "$@"
    }
    
    # Simulate network failure
    with_network_failure() {
        local failure_rate="${1:-0.5}"
        shift
        
        # Random failure based on rate
        if (( $(echo "scale=2; $RANDOM/32768 < $failure_rate" | bc -l) )); then
            echo "NETWORK_ERROR: Connection failed" >&2
            return 1
        else
            "$@"
        fi
    }
    
    # Functions are automatically available in zsh
}

# Mock resource limitation
mock_resource_limits() {
    # Simulate CPU limitation
    with_cpu_limit() {
        local limit="${1:-50}"  # Percentage
        shift
        
        # Mock CPU limiting (simplified)
        nice -n 10 "$@"
    }
    
    # Simulate memory limitation
    with_memory_limit() {
        local limit="${1:-100}"  # MB
        shift
        
        # Mock memory limiting
        ulimit -v $((limit * 1024)) 2>/dev/null
        "$@"
    }
    
    # Functions are automatically available in zsh
}

# Mock terminal output for benchmark tests
mock_terminal_output() {
    # Mock print functions to suppress output during tests
    if [[ -n "${PURITY_BENCHMARK_MODE:-}" ]]; then
        print() {
            # Do nothing in benchmark mode
        }
        
        printf() {
            # Do nothing in benchmark mode
        }
        
        echo() {
            # Selective echo - only allow performance debug messages
            if [[ "$1" =~ "^(Average|Total|Benchmark)" ]]; then
                builtin echo "$@"
            fi
        }
    fi
}

# Performance benchmark utilities
mock_benchmark_setup() {
    # Set up terminal output mocking
    mock_terminal_output
    # Run benchmark
    benchmark() {
        local name="$1"
        local iterations="${2:-100}"
        local command="$3"
        
        local total_time=0
        local min_time=999999
        local max_time=0
        
        for ((i=0; i<iterations; i++)); do
            local time=$(measure_time eval "$command")
            total_time=$((total_time + time))
            [[ $time -lt $min_time ]] && min_time=$time
            [[ $time -gt $max_time ]] && max_time=$time
        done
        
        local avg_time=$((total_time / iterations))
        
        echo "BENCHMARK: $name"
        echo "  Iterations: $iterations"
        echo "  Average: ${avg_time}ms"
        echo "  Min: ${min_time}ms"
        echo "  Max: ${max_time}ms"
    }
    
    # Function is automatically available in zsh
}

# Clean up performance mocks
mock_performance_cleanup() {
    unset -f get_memory_usage track_memory_usage get_time_ms measure_time 2>/dev/null || true
    unset -f detect_memory_leak run_concurrent with_timeout 2>/dev/null || true
    unset -f with_network_delay with_network_failure 2>/dev/null || true
    unset -f with_cpu_limit with_memory_limit benchmark 2>/dev/null || true
    unset -f print printf echo get_reliable_time_ms mock_terminal_output run_silently 2>/dev/null || true
}

# Functions are automatically available in zsh