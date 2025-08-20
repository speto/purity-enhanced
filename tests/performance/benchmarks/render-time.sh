#!/usr/bin/env zsh
# Prompt render performance benchmark
# Measures average time for prompt rendering cycles

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

echo -e "${BLUE}Benchmark 2: Prompt render performance${NC}"

# Create a realistic test directory with a git repo
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
    rm -f benchmark_render.zsh
}
trap cleanup EXIT

cd "$TEST_DIR"

# Create a realistic git repository for testing
git init --quiet >/dev/null 2>&1
git config user.email "test@benchmark.local" >/dev/null 2>&1
git config user.name "Benchmark Test" >/dev/null 2>&1
mkdir -p src/{lib,tests} docs bin >/dev/null 2>&1
for i in {1..20}; do
    echo "// Test file $i" > "src/lib/file$i.js"
    echo "# Test doc $i" > "docs/doc$i.md"
done
git add . >/dev/null 2>&1
git commit -m "Initial commit" --quiet >/dev/null 2>&1

# Add some unstaged changes
echo "modified content" >> src/lib/file1.js
echo "new file" > src/lib/newfile.js

# Create a test script that measures prompt rendering
cat > benchmark_render.zsh << 'EOF'
# Disable all terminal output during benchmarking
setopt NO_PROMPT_SUBST
unsetopt PROMPT_SUBST

export FPATH="$1:$FPATH"
source "$1/purity-enhanced.zsh" >/dev/null 2>&1

# Setup without any output
prompt_purity_enhanced_setup >/dev/null 2>&1

# Measure multiple render cycles
total_time=0
iterations=20

for ((i=1; i<=iterations; i++)); do
    if command -v python3 >/dev/null 2>&1; then
        start=$(python3 -c "import time; print(int(time.time() * 1000))")
    else
        start="$(($(date +%s) * 1000))"
    fi
    
    # Simulate what happens on each command - completely silent
    PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_precmd >/dev/null 2>&1
    
    if command -v python3 >/dev/null 2>&1; then
        end=$(python3 -c "import time; print(int(time.time() * 1000))")
    else
        end="$(($(date +%s) * 1000))"
    fi
    
    duration=$((end - start))
    total_time=$((total_time + duration))
done

avg_time=$((total_time / iterations))
printf "RENDER_TIME:%d\n" "$avg_time"
EOF

# Execute the benchmark
render_output=$(zsh benchmark_render.zsh "$REPO_ROOT" 2>&1)

# Extract just the number after RENDER_TIME: using robust parsing
render_time=$(echo "$render_output" | tr '\n' ' ' | grep -oE "RENDER_TIME:[0-9]+" | head -1 | cut -d: -f2)

# Debug output if render_time is empty or invalid
if [[ -z "$render_time" || ! "$render_time" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Debug: render output was:${NC}"
    echo "$render_output" | head -10
    render_time="ERROR"
fi

# Output the result in original format
echo -e "Average render time: ${render_time}ms"

if [[ "$render_time" == "ERROR" ]]; then
    echo -e "${RED}✗ Benchmark failed to measure render time${NC}"
    exit_code=1
elif [[ $render_time -lt 50 ]]; then
    echo -e "${GREEN}✓ Excellent (< 50ms)${NC}"
    exit_code=0
elif [[ $render_time -lt 100 ]]; then
    echo -e "${YELLOW}⚠ Good (< 100ms)${NC}"
    exit_code=0
elif [[ $render_time -lt 150 ]]; then
    echo -e "${YELLOW}⚠ Acceptable for CI (< 150ms)${NC}"
    exit_code=0
else
    echo -e "${RED}✗ Slow (> 150ms)${NC}"
    exit_code=1
fi

# Output metric for orchestrator to parse (only if valid)
if [[ "$render_time" != "ERROR" ]]; then
    echo "METRIC:render_time:$render_time"
fi

echo ""
exit $exit_code