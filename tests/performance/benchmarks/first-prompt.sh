#!/usr/bin/env zsh
# First prompt setup timing benchmark
# Measures time until first prompt is ready after theme setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the repository root directory
REPO_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"

# Validate theme exists
if [[ ! -f "$REPO_ROOT/purity-enhanced.zsh" ]]; then
    echo -e "${RED}Error: purity-enhanced.zsh not found in $REPO_ROOT${NC}"
    exit 1
fi

echo -e "${BLUE}Benchmark 1: First prompt setup time${NC}"

# Helper function to measure time in milliseconds
get_time_ms() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    elif [[ "$(uname)" == "Linux" ]] && date +%s%3N >/dev/null 2>&1; then
        date +%s%3N
    else
        echo "$(($(date +%s) * 1000))"
    fi
}

# Create a minimal test directory with a git repo for consistent environment
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

cd "$TEST_DIR"
git init --quiet >/dev/null 2>&1
git config user.email "test@benchmark.local" >/dev/null 2>&1
git config user.name "Benchmark Test" >/dev/null 2>&1
echo "test" > test.txt
git add . >/dev/null 2>&1
git commit -m "Test commit" --quiet >/dev/null 2>&1

# Measure first prompt setup time
start_time=$(get_time_ms)

# Start a new zsh process and measure time until first prompt is ready
zsh_output=$(zsh -i -c "
export FPATH=\"$REPO_ROOT:\$FPATH\"
source \"$REPO_ROOT/purity-enhanced.zsh\"
prompt_purity_enhanced_setup
echo 'PROMPT_READY'
exit
" 2>/dev/null | head -1)

end_time=$(get_time_ms)
first_prompt_lag=$((end_time - start_time))

# Output the result in original format
echo -e "First prompt lag: ${first_prompt_lag}ms"

# Provide assessment
if [[ $first_prompt_lag -lt 100 ]]; then
    echo -e "${GREEN}✓ Excellent (< 100ms)${NC}"
    exit_code=0
elif [[ $first_prompt_lag -lt 200 ]]; then
    echo -e "${YELLOW}⚠ Good (< 200ms)${NC}"
    exit_code=0
elif [[ $first_prompt_lag -lt 300 ]]; then
    echo -e "${YELLOW}⚠ Acceptable for CI (< 300ms)${NC}"
    exit_code=0
else
    echo -e "${RED}✗ Slow (> 300ms)${NC}"
    exit_code=1
fi

# Output metric for orchestrator to parse
echo "METRIC:first_prompt_lag:$first_prompt_lag"

# Verify the process completed successfully
if [[ "$zsh_output" != "PROMPT_READY" ]]; then
    echo -e "${RED}✗ Theme setup failed${NC}"
    exit_code=1
fi

echo ""
exit $exit_code