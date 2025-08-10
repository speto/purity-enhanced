#!/usr/bin/env zsh
# Simple test runner for purity-enhanced theme

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Purity Enhanced Theme Tests ===${NC}\n"

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Check if ZUnit is installed
if ! command -v zunit &> /dev/null; then
    echo -e "${YELLOW}ZUnit not found. Installing locally...${NC}"
    
    # Install ZUnit locally
    if [[ ! -d ./vendor/zunit ]]; then
        mkdir -p vendor
        git clone https://github.com/zunit-zsh/zunit.git vendor/zunit
    fi
    
    # Add to PATH
    export PATH="$REPO_ROOT/vendor/zunit:$PATH"
fi

# Check for zsh-async
if [[ ! -f async.zsh ]] && [[ ! -d vendor/zsh-async ]]; then
    echo -e "${YELLOW}zsh-async not found. Installing locally...${NC}"
    mkdir -p vendor
    git clone https://github.com/mafredri/zsh-async.git vendor/zsh-async
    ln -sf vendor/zsh-async/async.zsh async.zsh
fi

# Run basic syntax check
echo -e "${BLUE}Running syntax check...${NC}"
if zsh -n purity-enhanced.zsh; then
    echo -e "${GREEN}✓ Syntax check passed${NC}\n"
else
    echo -e "${RED}✗ Syntax check failed${NC}\n"
    exit 1
fi

# Run ZUnit tests if available
if command -v zunit &> /dev/null && [[ -d tests ]]; then
    echo -e "${BLUE}Running ZUnit tests...${NC}"
    zunit tests
else
    # Fallback to basic tests
    echo -e "${BLUE}Running basic tests...${NC}\n"
    
    # Test loading the theme
    echo -n "Testing theme loading... "
    if zsh -c "source purity-enhanced.zsh && prompt_purity_enhanced_setup" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        exit 1
    fi
    
    # Test git functions exist
    echo -n "Testing git functions... "
    if zsh -c "source purity-enhanced.zsh && type prompt_purity_enhanced_git_action" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        exit 1
    fi
    
    # Test async functions exist
    echo -n "Testing async functions... "
    if zsh -c "source purity-enhanced.zsh && type prompt_purity_enhanced_async_available" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        exit 1
    fi
    
    echo -e "\n${GREEN}All basic tests passed!${NC}"
fi

echo -e "\n${BLUE}Tests completed successfully!${NC}"