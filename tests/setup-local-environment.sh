#!/usr/bin/env zsh
# Setup script for local test environment
# This ensures tests can run outside of Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setting up local test environment ===${NC}\n"

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Export critical environment variables
export ZUNIT_TEST_ROOT="$REPO_ROOT"
export THEME_FILE="$REPO_ROOT/purity-enhanced.zsh"
export PURITY_TEST_DIR="$REPO_ROOT/tests"
export FPATH="$REPO_ROOT:$FPATH"
export PATH="$REPO_ROOT:$PATH"

# Check for ZUnit
echo -e "${BLUE}Checking for ZUnit...${NC}"
if ! command -v zunit &> /dev/null; then
    echo -e "${YELLOW}⚠ ZUnit not found. Installing ZUnit...${NC}"
    
    # Try to install ZUnit
    if command -v brew &> /dev/null; then
        echo "Installing ZUnit via Homebrew..."
        brew install zunit-zsh/zunit/zunit
    else
        echo -e "${RED}Error: ZUnit not found and cannot auto-install.${NC}"
        echo "Please install ZUnit manually: https://github.com/zunit-zsh/zunit"
        exit 1
    fi
fi
echo -e "${GREEN}✓ ZUnit found: $(command -v zunit)${NC}"

# Check for zsh-async (optional but recommended)
echo -e "${BLUE}Checking for zsh-async...${NC}"
if [[ -d "/usr/share/zsh/site-functions" ]] && [[ -f "/usr/share/zsh/site-functions/async.zsh" ]]; then
    echo -e "${GREEN}✓ zsh-async found in system${NC}"
    export ASYNC_AVAILABLE=1
elif [[ -d "$REPO_ROOT/async" ]]; then
    echo -e "${GREEN}✓ zsh-async found in project${NC}"
    export ASYNC_AVAILABLE=1
    export FPATH="$REPO_ROOT/async:$FPATH"
else
    echo -e "${YELLOW}⚠ zsh-async not found (async tests will be skipped)${NC}"
    export ASYNC_AVAILABLE=0
fi

# Verify helpers directory
echo -e "${BLUE}Verifying test helpers...${NC}"
if [[ ! -d "$PURITY_TEST_DIR/helpers" ]]; then
    echo -e "${RED}Error: Test helpers directory not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Test helpers found${NC}"

# Create a wrapper script for consistent test execution
echo -e "${BLUE}Creating test wrapper...${NC}"
cat > "$REPO_ROOT/tests/run-local-test.sh" << 'EOF'
#!/usr/bin/env zsh
# Wrapper script for running individual test files locally

# Set up environment
export ZUNIT_TEST_ROOT="${ZUNIT_TEST_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export THEME_FILE="$ZUNIT_TEST_ROOT/purity-enhanced.zsh"
export PURITY_TEST_DIR="$ZUNIT_TEST_ROOT/tests"
export FPATH="$ZUNIT_TEST_ROOT:$FPATH"
export PATH="$ZUNIT_TEST_ROOT:$PATH"

# Enable debug mode if requested
if [[ -n "${DEBUG_TESTS:-}" ]]; then
    export HELPERS_DEBUG=1
fi

# Change to repo root for consistent path resolution
cd "$ZUNIT_TEST_ROOT"

# Run the test
if [[ -n "$1" ]]; then
    echo "Running test: $1"
    zunit "$1"
else
    echo "Usage: $0 <test-file>"
    echo "Example: $0 tests/unit/core.zunit"
    exit 1
fi
EOF
chmod +x "$REPO_ROOT/tests/run-local-test.sh"

echo -e "${GREEN}✓ Test wrapper created${NC}"

# Run environment validation
echo -e "\n${BLUE}Validating environment...${NC}"
if source tests/validate-environment.sh; then
    echo -e "${GREEN}✓ Environment validation passed${NC}"
else
    echo -e "${YELLOW}⚠ Environment validation had issues${NC}"
fi

echo -e "\n${GREEN}=== Local environment setup complete ===${NC}"
echo -e "${BLUE}You can now run tests with:${NC}"
echo "  • All tests: zunit tests/"
echo "  • Specific test: ./tests/run-local-test.sh tests/unit/core.zunit"
echo "  • With debug: DEBUG_TESTS=1 ./tests/run-local-test.sh tests/unit/core.zunit"
echo ""
echo -e "${YELLOW}Note: For best results, use Docker: make test${NC}"