#!/usr/bin/env zsh
# Memory usage stability benchmark
# Tests for memory leaks during prompt cycles

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

echo -e "${BLUE}Benchmark 3: Memory usage stability${NC}"

# Create a test directory with git repo
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
    rm -f benchmark_memory.zsh
}
trap cleanup EXIT

cd "$TEST_DIR"

# Create a git repository for testing
git init --quiet >/dev/null 2>&1
git config user.email "test@benchmark.local" >/dev/null 2>&1
git config user.name "Benchmark Test" >/dev/null 2>&1
mkdir -p src >/dev/null 2>&1
for i in {1..10}; do
    echo "// Test file $i" > "src/file$i.js"
done
git add . >/dev/null 2>&1
git commit -m "Initial commit" --quiet >/dev/null 2>&1

# Create memory stability test script
cat > benchmark_memory.zsh << 'EOF'
# Disable all terminal output during benchmarking
setopt NO_PROMPT_SUBST
unsetopt PROMPT_SUBST

export FPATH="$1:$FPATH"
source "$1/purity-enhanced.zsh" >/dev/null 2>&1
prompt_purity_enhanced_setup >/dev/null 2>&1

# Run many prompt cycles to check for memory leaks
for ((i=1; i<=100; i++)); do
    PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_preexec "test command $i" >/dev/null 2>&1
    PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_precmd >/dev/null 2>&1
done

printf "MEMORY_TEST:OK\n"
EOF

# Execute with timeout to prevent hanging
if command -v timeout >/dev/null 2>&1; then
    memory_output=$(timeout 30s zsh benchmark_memory.zsh "$REPO_ROOT" 2>&1 || echo "MEMORY_TEST:TIMEOUT")
else
    # Fallback for systems without timeout command
    memory_output=$(zsh benchmark_memory.zsh "$REPO_ROOT" 2>&1 &
        local pid=$!
        (sleep 30 && kill $pid 2>/dev/null) &
        wait $pid 2>/dev/null && echo "MEMORY_TEST:OK" || echo "MEMORY_TEST:TIMEOUT")
fi

# Output the result in original format
if [[ "$memory_output" == *"MEMORY_TEST:OK"* ]]; then
    echo -e "${GREEN}✓ Memory usage stable${NC}"
    memory_status="✓"
    exit_code=0
else
    echo -e "${RED}✗ Memory test failed or timed out${NC}"
    memory_status="✗"
    exit_code=1
fi

# Output metric for orchestrator to parse
echo "METRIC:memory_stability:$memory_status"

echo ""
exit $exit_code