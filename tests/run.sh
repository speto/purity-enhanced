#!/usr/bin/env zsh
# Test runner for purity-enhanced theme

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
# Store original directory for cleanup
ORIGINAL_DIR="$(pwd)"
cd "$REPO_ROOT"

# Set up environment for ZSH testing
export FPATH="$REPO_ROOT:$FPATH"
export PATH="$REPO_ROOT:$PATH"
export PURITY_TEST_DIR="${REPO_ROOT}/tests"

# Validate helpers directory exists
if [[ ! -d "${PURITY_TEST_DIR}/helpers" ]]; then
    echo -e "${RED}Error: Test helpers directory not found at ${PURITY_TEST_DIR}/helpers${NC}"
    echo -e "${YELLOW}This directory is required for test execution.${NC}"
    exit 1
fi

# Validate test environment
echo -e "${BLUE}Validating test environment...${NC}"
if ! source tests/validate-environment.sh; then
    echo -e "${RED}Environment validation failed. Aborting tests.${NC}"
    exit 1
fi
echo ""

# Check if ZUnit is available
if ! command -v zunit &> /dev/null; then
    echo -e "${RED}Error: ZUnit not found!${NC}"
    echo -e "${YELLOW}Please use Docker to run tests:${NC}"
    echo "  make test"
    exit 1
fi

# Check for zsh-async availability in test environment
echo -e "${BLUE}Checking for zsh-async availability...${NC}"
if [[ -d "${REPO_ROOT}/async" ]] || command -v async &> /dev/null || [[ -n "${ASYNC_VERSION}" ]]; then
    echo -e "${GREEN}✓ zsh-async is available${NC}"
    export ASYNC_AVAILABLE=1
else
    echo -e "${YELLOW}⚠ zsh-async not found, async tests will be skipped${NC}"
    export ASYNC_AVAILABLE=0
fi
echo ""

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
    echo -e "${BLUE}Running modular ZUnit tests...${NC}\n"
    
    # Function to run test suite with error handling
    run_test_suite() {
        local suite_path="$1"
        local suite_name="$2"
        
        # Validate inputs
        if [[ -z "$suite_path" ]] || [[ -z "$suite_name" ]]; then
            echo -e "${RED}Error: Invalid parameters to run_test_suite${NC}"
            return 1
        fi
        
        # Convert to absolute path if relative
        if [[ "$suite_path" != /* ]]; then
            suite_path="${REPO_ROOT}/${suite_path}"
        fi
        
        # Validate suite path exists and has test files
        if [[ -d "$suite_path" ]] && [[ -n "$(find "$suite_path" -name "*.zunit" 2>/dev/null)" ]]; then
            echo -e "${BLUE}Running $suite_name tests...${NC}"
            
            # Ensure we're in the correct working directory before running tests
            if ! cd "$REPO_ROOT" 2>/dev/null; then
                echo -e "${RED}Error: Could not change to repository root directory: $REPO_ROOT${NC}"
                return 1
            fi
            
            # Validate we're in the right place
            if [[ ! -f "purity-enhanced.zsh" ]]; then
                echo -e "${RED}Error: purity-enhanced.zsh not found in current directory${NC}"
                echo -e "${YELLOW}Current directory: $(pwd)${NC}"
                return 1
            fi
            
            # Set up test environment variables
            export ZUNIT_TEST_ROOT="$REPO_ROOT"
            export THEME_FILE="$REPO_ROOT/purity-enhanced.zsh"
            export PURITY_TEST_DIR="${REPO_ROOT}/tests"
            
            # Capture ZUnit output with better error handling
            local output
            local exit_code
            if output=$(zunit "$suite_path" 2>&1); then
                exit_code=0
            else
                exit_code=$?
            fi
            
            # Display the output
            echo "$output"
            
            # Parse statistics from output with improved robustness
            local clean_output=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')
            
            # More robust parsing with fallbacks
            local passed=0
            local failed=0
            local errors=0
            local skipped=0
            local warnings=0
            
            # Try multiple patterns to extract counts
            if echo "$clean_output" | grep -q "Passed"; then
                passed=$(echo "$clean_output" | grep -E "(✔|Passed)" | grep -oE '[0-9]+' | tail -1 || echo "0")
            fi
            
            if echo "$clean_output" | grep -q "Failed"; then
                failed=$(echo "$clean_output" | grep -E "(✘|Failed)" | grep -oE '[0-9]+' | tail -1 || echo "0")
            fi
            
            if echo "$clean_output" | grep -q "Error"; then
                errors=$(echo "$clean_output" | grep -E "(‼|Error)" | grep -oE '[0-9]+' | tail -1 || echo "0")
            fi
            
            if echo "$clean_output" | grep -q "Skipped"; then
                skipped=$(echo "$clean_output" | grep -E "(●|Skipped)" | grep -oE '[0-9]+' | tail -1 || echo "0")
            fi
            
            if echo "$clean_output" | grep -q "Warning"; then
                warnings=$(echo "$clean_output" | grep -E "(‼|Warning)" | grep -oE '[0-9]+' | tail -1 || echo "0")
            fi
            
            # Add to totals (use 0 if parsing failed)
            TOTAL_PASSED=$((TOTAL_PASSED + ${passed:-0}))
            TOTAL_FAILED=$((TOTAL_FAILED + ${failed:-0}))
            TOTAL_ERRORS=$((TOTAL_ERRORS + ${errors:-0}))
            TOTAL_SKIPPED=$((TOTAL_SKIPPED + ${skipped:-0}))
            TOTAL_WARNINGS=$((TOTAL_WARNINGS + ${warnings:-0}))
            
            if [[ $exit_code -eq 0 ]]; then
                echo -e "${GREEN}✓ $suite_name tests passed${NC}\n"
            else
                echo -e "${RED}✗ $suite_name tests failed${NC}\n"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠ $suite_name test directory not found, skipping${NC}\n"
        fi
        return 0
    }
    
    # Track overall test results
    FAILED_SUITES=()
    
    # Track total statistics across all suites
    TOTAL_PASSED=0
    TOTAL_FAILED=0
    TOTAL_ERRORS=0
    TOTAL_SKIPPED=0
    TOTAL_WARNINGS=0
    TOTAL_TESTS=0
    
    # Run legacy tests first (theme.zunit)
    if [[ -f "$REPO_ROOT/tests/theme.zunit" ]]; then
        echo -e "${BLUE}Running legacy tests (theme.zunit)...${NC}"
        
        # Ensure we're in the correct working directory before running tests
        if ! cd "$REPO_ROOT" 2>/dev/null; then
            echo -e "${RED}Error: Could not change to repository root directory: $REPO_ROOT${NC}"
            FAILED_SUITES+=("legacy")
        else
            # Validate we're in the right place
            if [[ ! -f "purity-enhanced.zsh" ]]; then
                echo -e "${RED}Error: purity-enhanced.zsh not found in current directory${NC}"
                echo -e "${YELLOW}Current directory: $(pwd)${NC}"
                FAILED_SUITES+=("legacy")
            else
                # Set up test environment
                export ZUNIT_TEST_ROOT="$REPO_ROOT"
                export THEME_FILE="$REPO_ROOT/purity-enhanced.zsh"
                export PURITY_TEST_DIR="${REPO_ROOT}/tests"
                
                # Capture ZUnit output with better error handling
                local output
                local exit_code
                if output=$(zunit "$REPO_ROOT/tests/theme.zunit" 2>&1); then
                    exit_code=0
                else
                    exit_code=$?
                fi
                
                # Display the output
                echo "$output"
                
                # Parse statistics from output (strip ANSI codes first)
                local clean_output=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')
                local passed=$(echo "$clean_output" | grep -E "✔.*Passed" | sed -E 's/.*Passed[[:space:]]+([0-9]+).*/\1/' | tail -1)
                local failed=$(echo "$clean_output" | grep -E "✘.*Failed" | sed -E 's/.*Failed[[:space:]]+([0-9]+).*/\1/' | tail -1)
                local errors=$(echo "$clean_output" | grep -E "‼.*Errors" | sed -E 's/.*Errors[[:space:]]+([0-9]+).*/\1/' | tail -1)
                local skipped=$(echo "$clean_output" | grep -E "●.*Skipped" | sed -E 's/.*Skipped[[:space:]]+([0-9]+).*/\1/' | tail -1)
                local warnings=$(echo "$clean_output" | grep -E "‼.*Warnings" | sed -E 's/.*Warnings[[:space:]]+([0-9]+).*/\1/' | tail -1)
                
                # Add to totals (use 0 if parsing failed)
                TOTAL_PASSED=$((TOTAL_PASSED + ${passed:-0}))
                TOTAL_FAILED=$((TOTAL_FAILED + ${failed:-0}))
                TOTAL_ERRORS=$((TOTAL_ERRORS + ${errors:-0}))
                TOTAL_SKIPPED=$((TOTAL_SKIPPED + ${skipped:-0}))
                TOTAL_WARNINGS=$((TOTAL_WARNINGS + ${warnings:-0}))
                
                if [[ $exit_code -eq 0 ]]; then
                    echo -e "${GREEN}✓ Legacy tests passed${NC}\n"
                else
                    echo -e "${RED}✗ Legacy tests failed${NC}\n"
                    FAILED_SUITES+=("legacy")
                fi
            fi
        fi
    fi
    
    # Run unit tests
    if ! run_test_suite "tests/unit" "Unit"; then
        FAILED_SUITES+=("unit")
    fi
    
    # Run integration tests
    if ! run_test_suite "tests/integration" "Integration"; then
        FAILED_SUITES+=("integration")
    fi
    
    # Run compatibility tests
    if ! run_test_suite "tests/compatibility" "Compatibility"; then
        FAILED_SUITES+=("compatibility")
    fi
    
    # Note: Benchmark tests removed in favor of real-world performance testing
    # Use tests/performance-benchmark.sh for performance evaluation
    
    # Calculate total tests
    TOTAL_TESTS=$((TOTAL_PASSED + TOTAL_FAILED + TOTAL_ERRORS + TOTAL_SKIPPED))
    
    # Display final aggregate results
    echo -e "${BLUE}=== Final Test Results Summary ===${NC}\n"
    echo -e "Total tests run: ${TOTAL_TESTS}\n"
    
    echo -e "${YELLOW}Results${NC}"
    echo -e "${GREEN}✔${NC} Passed      ${TOTAL_PASSED}"
    echo -e "${RED}✘${NC} Failed      ${TOTAL_FAILED}"
    echo -e "${RED}‼${NC} Errors      ${TOTAL_ERRORS}"
    echo -e "${BLUE}●${NC} Skipped     ${TOTAL_SKIPPED}"
    echo -e "${YELLOW}‼${NC} Warnings    ${TOTAL_WARNINGS}"
    echo ""
    
    # Report overall results
    if [[ ${#FAILED_SUITES[@]} -eq 0 ]]; then
        echo -e "${GREEN}🎉 All test suites passed!${NC}"
    else
        echo -e "${RED}❌ Failed test suites: ${FAILED_SUITES[*]}${NC}"
        echo -e "${YELLOW}💡 Run individual suites with: zunit tests/<suite-name>${NC}"
        exit 1
    fi
else
    # Fallback to basic tests
    echo -e "${BLUE}Running basic tests...${NC}\n"
    
    # Ensure we're in the correct working directory for fallback tests
    if ! cd "$REPO_ROOT" 2>/dev/null; then
        echo -e "${RED}Error: Could not change to repository root directory: $REPO_ROOT${NC}"
        exit 1
    fi
    
    # Validate we're in the right place
    if [[ ! -f "purity-enhanced.zsh" ]]; then
        echo -e "${RED}Error: purity-enhanced.zsh not found in current directory${NC}"
        echo -e "${YELLOW}Current directory: $(pwd)${NC}"
        exit 1
    fi
    
    # Set up test environment for fallback tests
    export PURITY_TEST_DIR="${REPO_ROOT}/tests"
    
    # Test loading the theme
    echo -n "Testing theme loading... "
    local load_error
    if load_error=$(zsh -c "source purity-enhanced.zsh && prompt_purity_enhanced_setup" 2>&1); then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Error details: $load_error${NC}"
        exit 1
    fi
    
    # Test git functions exist
    echo -n "Testing git functions... "
    local git_error
    if git_error=$(zsh -c "source purity-enhanced.zsh && type prompt_purity_enhanced_git_action" 2>&1); then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Error details: $git_error${NC}"
        exit 1
    fi
    
    # Test async functions exist
    echo -n "Testing async functions... "
    local async_error
    if async_error=$(zsh -c "source purity-enhanced.zsh && type prompt_purity_enhanced_async_available" 2>&1); then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Error details: $async_error${NC}"
        exit 1
    fi
    
    echo -e "\n${GREEN}All basic tests passed!${NC}"
fi

# Clean up and restore original directory
cd "$ORIGINAL_DIR"

echo -e "\n${BLUE}Tests completed successfully!${NC}"