#!/usr/bin/env zsh
# Purity Enhanced Performance Benchmark Orchestrator
#
# This script runs all performance benchmarks and generates a unified report
# like the original performance-benchmark.sh but with modular structure.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the repository root directory
SCRIPT_DIR="${0:A:h}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PERFORMANCE_DIR="$SCRIPT_DIR"

echo -e "${BLUE}=== Purity Enhanced Performance Benchmark ===${NC}\\n"

# Validate environment
if [[ ! -f "$REPO_ROOT/purity-enhanced.zsh" ]]; then
    echo -e "${RED}Error: purity-enhanced.zsh not found in $REPO_ROOT${NC}"
    exit 1
fi

# Check for required tools
echo -e "${BLUE}Setting up test environment...${NC}"
if ! git --version >/dev/null 2>&1; then
    echo -e "${RED}Error: git is required for benchmarks${NC}"
    exit 1
fi

if command -v python3 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Python3 available for high-precision timing${NC}"
else
    echo -e "${YELLOW}⚠ Python3 not available, using fallback timing${NC}"
fi

echo -e "${GREEN}✓ Test environment ready${NC}\\n"

# List of benchmark scripts to run
BENCHMARK_SCRIPTS=(
    "first-prompt.sh"
    "render-time.sh" 
    "memory-stability.sh"
    "async-operations.sh"
)

# Variables to store benchmark results
typeset -A BENCHMARK_METRICS
typeset -a FAILED_BENCHMARKS
TOTAL_BENCHMARKS=0
PASSED_BENCHMARKS=0

# Function to run a single benchmark script
run_benchmark_script() {
    local script_name="$1"
    local script_path="$PERFORMANCE_DIR/benchmarks/$script_name"
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}✗ Benchmark script not found: $script_path${NC}"
        FAILED_BENCHMARKS+=("$script_name (missing file)")
        return 1
    fi
    
    # Run the benchmark script and capture both output and metrics
    local output
    local exit_code
    local start_time=$(date +%s)
    
    if output=$(cd "$REPO_ROOT" && "$script_path" "$REPO_ROOT" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Display the benchmark output (everything except METRIC lines)
    echo "$output" | grep -v "^METRIC:" 
    
    # Extract metrics from output
    local metrics=$(echo "$output" | grep "^METRIC:" 2>/dev/null || true)
    
    # Store metrics for summary
    if [[ -n "$metrics" ]]; then
        while IFS= read -r metric_line; do
            # Simple parsing using cut instead of regex
            if [[ "$metric_line" == METRIC:* ]]; then
                local metric_name=$(echo "$metric_line" | cut -d: -f2)
                local metric_value=$(echo "$metric_line" | cut -d: -f3)
                BENCHMARK_METRICS[$metric_name]="$metric_value"
            fi
        done <<< "$metrics"
    fi
    
    TOTAL_BENCHMARKS=$((TOTAL_BENCHMARKS + 1))
    
    if [[ $exit_code -eq 0 ]]; then
        PASSED_BENCHMARKS=$((PASSED_BENCHMARKS + 1))
    else
        local benchmark_name="${script_name%.sh}"
        FAILED_BENCHMARKS+=("$benchmark_name")
    fi
    
    return $exit_code
}

# Function to show performance summary like the original
show_performance_summary() {
    echo -e "${BLUE}=== Performance Summary ===${NC}"
    
    # Display metrics in the same format as original
    local first_prompt="${BENCHMARK_METRICS[first_prompt_lag]:-ERROR}"
    local render_time="${BENCHMARK_METRICS[render_time]:-ERROR}"
    local async_time="${BENCHMARK_METRICS[async_time]:-ERROR}"
    local memory_status="${BENCHMARK_METRICS[memory_stability]:-ERROR}"
    
    echo -e "First prompt lag:    ${first_prompt}ms"
    echo -e "Average render time: ${render_time}ms"
    echo -e "Async operations:    ${async_time}ms"
    echo -e "Memory stability:    $memory_status"
    echo ""
}

# Function to calculate overall score like the original
calculate_overall_score() {
    local overall_score=0
    local first_prompt="${BENCHMARK_METRICS[first_prompt_lag]:-999999}"
    local render_time="${BENCHMARK_METRICS[render_time]:-999999}"
    local async_time="${BENCHMARK_METRICS[async_time]:-999999}"
    local memory_status="${BENCHMARK_METRICS[memory_stability]:-ERROR}"
    
    # Use the same thresholds as original (more lenient for Docker environment)
    [[ "$first_prompt" =~ ^[0-9]+$ && $first_prompt -lt 300 ]] && overall_score=$((overall_score + 1))
    [[ "$render_time" =~ ^[0-9]+$ && $render_time -lt 150 ]] && overall_score=$((overall_score + 1))
    [[ "$async_time" =~ ^[0-9]+$ && $async_time -lt 250 ]] && overall_score=$((overall_score + 1))
    [[ "$memory_status" == "✓" ]] && overall_score=$((overall_score + 1))
    
    echo -e "${BLUE}Overall Performance Score: ${overall_score}/4${NC}"
    
    if [[ $overall_score -eq 4 ]]; then
        echo -e "${GREEN}🎉 Excellent overall performance!${NC}"
        return 0
    elif [[ $overall_score -ge 2 ]]; then
        echo -e "${YELLOW}⚠ Good performance with room for improvement${NC}"
        if [[ ${#FAILED_BENCHMARKS[@]} -gt 0 ]]; then
            echo -e "${YELLOW}Issues in: ${FAILED_BENCHMARKS[*]}${NC}"
        fi
        return 0
    else
        echo -e "${RED}❌ Performance issues detected${NC}"
        if [[ ${#FAILED_BENCHMARKS[@]} -gt 0 ]]; then
            echo -e "${RED}Failed benchmarks: ${FAILED_BENCHMARKS[*]}${NC}"
        fi
        return 1
    fi
}

# Function to show recommendations
show_recommendations() {
    echo -e "${BLUE}For more detailed analysis, consider using zsh-bench:${NC}"
    echo -e "  ${CYAN}git clone https://github.com/romkatv/zsh-bench.git${NC}"
    echo -e "  ${CYAN}cd zsh-bench${NC}"
    echo -e "  ${CYAN}./zsh-bench${NC}"
    echo ""
    
    if [[ ${#FAILED_BENCHMARKS[@]} -gt 0 ]]; then
        echo -e "${BLUE}To investigate individual benchmarks:${NC}"
        for failed in "${FAILED_BENCHMARKS[@]}"; do
            echo -e "  ${CYAN}$PERFORMANCE_DIR/benchmarks/${failed}.sh${NC}"
        done
        echo ""
    fi
}

# Main execution
main() {
    local start_time=$(date +%s)
    local overall_exit_code=0
    
    # Run each benchmark script
    for script in "${BENCHMARK_SCRIPTS[@]}"; do
        if ! run_benchmark_script "$script"; then
            overall_exit_code=1
        fi
    done
    
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    # Show results exactly like the original
    show_performance_summary
    
    # Calculate and show overall score
    if ! calculate_overall_score; then
        overall_exit_code=1
    fi
    
    echo ""
    show_recommendations
    
    # Clean up any temporary files created by benchmarks
    find "$PERFORMANCE_DIR/benchmarks" -name "benchmark_*.zsh" -delete 2>/dev/null || true
    
    echo -e "${GREEN}Performance benchmark completed successfully!${NC}"
    
    return $overall_exit_code
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --list         List available benchmark scripts"
        echo "  --single FILE  Run only the specified benchmark script"
        echo ""
        echo "Examples:"
        echo "  $0                           # Run all benchmarks"
        echo "  $0 --single first-prompt     # Run only first-prompt benchmark"
        echo "  $0 --list                   # List available benchmarks"
        exit 0
        ;;
    --list)
        echo "Available benchmark scripts:"
        for script in "${BENCHMARK_SCRIPTS[@]}"; do
            echo "  ${script%.sh}"
        done
        exit 0
        ;;
    --single)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}Error: --single requires a benchmark name${NC}"
            exit 1
        fi
        
        local single_script="${2%.sh}.sh"
        if [[ " ${BENCHMARK_SCRIPTS[*]} " == *" $single_script "* ]]; then
            BENCHMARK_SCRIPTS=("$single_script")
            echo -e "${BLUE}Running single benchmark: ${single_script%.sh}${NC}"
            echo ""
        else
            echo -e "${RED}Error: Benchmark '$2' not found${NC}"
            echo "Available: ${BENCHMARK_SCRIPTS[*]// /, }"
            exit 1
        fi
        ;;
    "")
        # Run all benchmarks (default)
        ;;
    *)
        echo -e "${RED}Error: Unknown option '$1'${NC}"
        echo "Use --help for usage information"
        exit 1
        ;;
esac

# Run main function
main