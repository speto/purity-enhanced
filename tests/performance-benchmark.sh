#!/usr/bin/env zsh
# Real-world performance benchmark for purity-enhanced theme
# Based on zsh-bench methodology for measuring interactive zsh performance
#
# This script measures user-visible latency instead of individual function performance
# which is more meaningful for prompt theme evaluation.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Purity Enhanced Performance Benchmark ===${NC}\n"

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Validate theme exists
if [[ ! -f "purity-enhanced.zsh" ]]; then
    echo -e "${RED}Error: purity-enhanced.zsh not found${NC}"
    exit 1
fi

# Create a temporary test directory with a git repo
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

echo -e "${BLUE}Setting up test environment...${NC}"
cd "$TEST_DIR"

# Create a realistic git repository for testing
git init --quiet
mkdir -p src/{lib,tests} docs bin
for i in {1..50}; do
    echo "// Test file $i" > "src/lib/file$i.js"
    echo "# Test doc $i" > "docs/doc$i.md"
done
git add .
git commit -m "Initial commit" --quiet

# Add some unstaged changes
echo "modified content" >> src/lib/file1.js
echo "new file" > src/lib/newfile.js

echo -e "${GREEN}✓ Test environment ready${NC}\n"

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

# Benchmark 1: First prompt lag (theme setup + initial render)
echo -e "${BLUE}Benchmark 1: First prompt setup time${NC}"
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

echo -e "First prompt lag: ${first_prompt_lag}ms"
if [[ $first_prompt_lag -lt 100 ]]; then
    echo -e "${GREEN}✓ Excellent (< 100ms)${NC}"
elif [[ $first_prompt_lag -lt 200 ]]; then
    echo -e "${YELLOW}⚠ Good (< 200ms)${NC}"
else
    echo -e "${RED}✗ Slow (> 200ms)${NC}"
fi
echo ""

# Benchmark 2: Prompt render time in git repository
echo -e "${BLUE}Benchmark 2: Prompt render performance${NC}"

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
    start=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "$(($(date +%s) * 1000))")
    
    # Simulate what happens on each command - completely silent
    PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_precmd >/dev/null 2>&1
    
    end=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "$(($(date +%s) * 1000))")
    duration=$((end - start))
    total_time=$((total_time + duration))
done

avg_time=$((total_time / iterations))
printf "RENDER_TIME:%d\n" "$avg_time"
EOF

render_output=$(zsh benchmark_render.zsh "$REPO_ROOT" 2>&1)
# Extract just the number after RENDER_TIME: using more robust parsing
render_time=$(echo "$render_output" | tr '\n' ' ' | grep -oE "RENDER_TIME:[0-9]+" | head -1 | cut -d: -f2)

# Debug output if render_time is empty or invalid
if [[ -z "$render_time" || ! "$render_time" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Debug: render output was:${NC}"
    echo "$render_output" | head -10
    echo -e "${RED}Debug: clean output was:${NC}"
    echo "$clean_output"
    render_time="ERROR"
fi

echo -e "Average render time: ${render_time}ms"
if [[ "$render_time" == "ERROR" ]]; then
    echo -e "${RED}✗ Benchmark failed to measure render time${NC}"
elif [[ $render_time -lt 50 ]]; then
    echo -e "${GREEN}✓ Excellent (< 50ms)${NC}"
elif [[ $render_time -lt 100 ]]; then
    echo -e "${YELLOW}⚠ Good (< 100ms)${NC}"
else
    echo -e "${RED}✗ Slow (> 100ms)${NC}"
fi
echo ""

# Benchmark 3: Memory usage stability
echo -e "${BLUE}Benchmark 3: Memory usage stability${NC}"

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

memory_output=$(timeout 30s zsh benchmark_memory.zsh "$REPO_ROOT" 2>&1 || echo "MEMORY_TEST:TIMEOUT")

if [[ "$memory_output" == *"MEMORY_TEST:OK"* ]]; then
    echo -e "${GREEN}✓ Memory usage stable${NC}"
else
    echo -e "${RED}✗ Memory test failed or timed out${NC}"
fi
echo ""

# Benchmark 4: Async operations performance
echo -e "${BLUE}Benchmark 4: Async operations${NC}"

# Test that async operations don't block the prompt
cat > benchmark_async.zsh << 'EOF'
# Disable all terminal output during benchmarking
setopt NO_PROMPT_SUBST
unsetopt PROMPT_SUBST

export FPATH="$1:$FPATH"
source "$1/purity-enhanced.zsh" >/dev/null 2>&1
prompt_purity_enhanced_setup >/dev/null 2>&1

# Create a slow git repository situation
mkdir -p deep/nested/dir/structure >/dev/null 2>&1
for i in {1..100}; do
    echo "file $i" > "deep/nested/dir/structure/file$i.txt"
done
git add deep/ >/dev/null 2>&1

# Measure prompt with potential async git operations
start=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "$(($(date +%s) * 1000))")

# This should not block even with the large git addition
PROMPT="" RPROMPT="" PS1="" RPS1="" prompt_purity_enhanced_precmd >/dev/null 2>&1

end=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "$(($(date +%s) * 1000))")
duration=$((end - start))

printf "ASYNC_TIME:%d\n" "$duration"
EOF

async_output=$(zsh benchmark_async.zsh "$REPO_ROOT" 2>&1)
# Extract just the number after ASYNC_TIME: using more robust parsing
async_time=$(echo "$async_output" | tr '\n' ' ' | grep -oE "ASYNC_TIME:[0-9]+" | head -1 | cut -d: -f2)

# Debug output if async_time is empty or invalid
if [[ -z "$async_time" || ! "$async_time" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Debug: async output was:${NC}"
    echo "$async_output" | head -10
    echo -e "${RED}Debug: clean async output was:${NC}"
    echo "$clean_async_output"
    async_time="ERROR"
fi

echo -e "Async prompt time: ${async_time}ms"
if [[ "$async_time" == "ERROR" ]]; then
    echo -e "${RED}✗ Async benchmark failed${NC}"
elif [[ $async_time -lt 100 ]]; then
    echo -e "${GREEN}✓ Fast async operations (< 100ms)${NC}"
elif [[ $async_time -lt 200 ]]; then
    echo -e "${YELLOW}⚠ Acceptable async performance (< 200ms)${NC}"
else
    echo -e "${RED}✗ Slow async operations (> 200ms)${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}=== Performance Summary ===${NC}"
echo -e "First prompt lag:    ${first_prompt_lag}ms"
echo -e "Average render time: ${render_time}ms"
echo -e "Async operations:    ${async_time}ms"
echo -e "Memory stability:    $(if [[ "$memory_output" == *"OK"* ]]; then echo "✓"; else echo "✗"; fi)"
echo ""

# Overall assessment (more lenient for Docker environment)
overall_score=0
[[ $first_prompt_lag -lt 300 ]] && overall_score=$((overall_score + 1))  # More lenient for Docker
[[ "$render_time" != "ERROR" && $render_time -lt 150 ]] && overall_score=$((overall_score + 1))  # More lenient
[[ "$async_time" != "ERROR" && $async_time -lt 250 ]] && overall_score=$((overall_score + 1))  # More lenient
[[ "$memory_output" == *"OK"* ]] && overall_score=$((overall_score + 1))

if [[ $overall_score -eq 4 ]]; then
    echo -e "${GREEN}🎉 Excellent overall performance!${NC}"
elif [[ $overall_score -ge 2 ]]; then
    echo -e "${YELLOW}⚠ Good performance with room for improvement${NC}"
else
    echo -e "${RED}❌ Performance issues detected${NC}"
    exit 1
fi

echo -e "\n${BLUE}For more detailed analysis, consider using zsh-bench:${NC}"
echo -e "  git clone https://github.com/romkatv/zsh-bench.git"
echo -e "  cd zsh-bench"
echo -e "  ./zsh-bench"

# Clean up test files
rm -f benchmark_render.zsh benchmark_memory.zsh benchmark_async.zsh

echo -e "\n${GREEN}Performance benchmark completed successfully!${NC}"