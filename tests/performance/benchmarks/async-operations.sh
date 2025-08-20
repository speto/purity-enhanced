#!/usr/bin/env zsh
# Async operations performance benchmark
# Tests that async operations don't block the prompt

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

echo -e "${BLUE}Benchmark 4: Async operations${NC}"

# Create a large test directory that could trigger slow git operations
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
    rm -f benchmark_async.zsh
}
trap cleanup EXIT

cd "$TEST_DIR"

# Create a git repository with many files
git init --quiet >/dev/null 2>&1
git config user.email "test@benchmark.local" >/dev/null 2>&1
git config user.name "Benchmark Test" >/dev/null 2>&1
mkdir -p deep/nested/dir/structure >/dev/null 2>&1
for i in {1..50}; do
    echo "file $i" > "deep/nested/dir/structure/file$i.txt"
done
git add . >/dev/null 2>&1
git commit -m "Initial large commit" --quiet >/dev/null 2>&1

# Create async benchmark script
cat > benchmark_async.zsh << 'EOF'
# Enable async operations for this test
unsetopt NO_PROMPT_SUBST
setopt PROMPT_SUBST

export FPATH="$1:$FPATH"
export PURITY_GIT_PULL=1  # Enable async git operations
source "$1/purity-enhanced.zsh" >/dev/null 2>&1
prompt_purity_enhanced_setup >/dev/null 2>&1

# Create a slow git repository situation
mkdir -p deep2/nested/dir/structure >/dev/null 2>&1
for i in {1..50}; do
    echo "file $i" > "deep2/nested/dir/structure/file$i.txt"
done
git add deep2/ >/dev/null 2>&1

# Measure prompt with potential async git operations
if command -v python3 >/dev/null 2>&1; then
    start=$(python3 -c "import time; print(int(time.time() * 1000))")
else
    start="$(($(date +%s) * 1000))"
fi

# This should not block even with the large git addition
PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_precmd >/dev/null 2>&1

if command -v python3 >/dev/null 2>&1; then
    end=$(python3 -c "import time; print(int(time.time() * 1000))")
else
    end="$(($(date +%s) * 1000))"
fi

duration=$((end - start))
printf "ASYNC_TIME:%d\n" "$duration"
EOF

# Execute the benchmark
async_output=$(zsh benchmark_async.zsh "$REPO_ROOT" 2>&1)

# Extract just the number after ASYNC_TIME: using robust parsing
async_time=$(echo "$async_output" | tr '\n' ' ' | grep -oE "ASYNC_TIME:[0-9]+" | head -1 | cut -d: -f2)

# Debug output if async_time is empty or invalid
if [[ -z "$async_time" || ! "$async_time" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Debug: async output was:${NC}"
    echo "$async_output" | head -10
    async_time="ERROR"
fi

# Output the result in original format
echo -e "Async prompt time: ${async_time}ms"

if [[ "$async_time" == "ERROR" ]]; then
    echo -e "${RED}✗ Async benchmark failed${NC}"
    exit_code=1
elif [[ $async_time -lt 100 ]]; then
    echo -e "${GREEN}✓ Fast async operations (< 100ms)${NC}"
    exit_code=0
elif [[ $async_time -lt 200 ]]; then
    echo -e "${YELLOW}⚠ Acceptable async performance (< 200ms)${NC}"
    exit_code=0
elif [[ $async_time -lt 250 ]]; then
    echo -e "${YELLOW}⚠ Acceptable for CI (< 250ms)${NC}"
    exit_code=0
else
    echo -e "${RED}✗ Slow async operations (> 250ms)${NC}"
    exit_code=1
fi

# Output metric for orchestrator to parse (only if valid)
if [[ "$async_time" != "ERROR" ]]; then
    echo "METRIC:async_time:$async_time"
fi

echo ""
exit $exit_code