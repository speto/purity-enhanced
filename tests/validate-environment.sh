#!/usr/bin/env zsh
# Environment validation script for test runner

validate_test_environment() {
    local errors=0
    local warnings=0
    
    echo "Validating test environment..."
    
    # Check ZSH version
    if [[ "${ZSH_VERSION%%.*}" -lt 5 ]]; then
        echo "Error: ZSH version 5.0+ required, found: $ZSH_VERSION" >&2
        ((errors++))
    fi
    
    # Check required commands
    local required_commands=("git" "zsh")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Required command not found: $cmd" >&2
            ((errors++))
        fi
    done
    
    # Check theme file exists
    if [[ ! -f "purity-enhanced.zsh" ]]; then
        echo "Error: Theme file not found: purity-enhanced.zsh" >&2
        ((errors++))
    fi
    
    # Check test directory structure
    if [[ ! -d "tests" ]]; then
        echo "Error: Tests directory not found" >&2
        ((errors++))
    else
        # Check for test files
        local test_files=(tests/*.zunit tests/*/*.zunit)
        if [[ ! -f "${test_files[1]}" ]]; then
            echo "Warning: No ZUnit test files found" >&2
            ((warnings++))
        fi
    fi
    
    # Check ZUnit if available
    if command -v zunit &>/dev/null; then
        echo "✓ ZUnit found: $(command -v zunit)"
        
        # Check ZUnit version
        if zunit --version &>/dev/null; then
            echo "✓ ZUnit version: $(zunit --version 2>/dev/null | head -1)"
        fi
    else
        echo "Warning: ZUnit not found - will use fallback tests" >&2
        ((warnings++))
    fi
    
    # Check dependencies
    if [[ ! -f "/usr/share/zsh/site-functions/async.zsh" ]] && [[ -z "$ZSH_ASYNC_LOADED" ]]; then
        echo "Warning: zsh-async not found in standard location" >&2
        ((warnings++))
    fi
    
    # Summary
    echo ""
    if [[ $errors -eq 0 ]]; then
        echo "✓ Environment validation passed"
        if [[ $warnings -gt 0 ]]; then
            echo "⚠ $warnings warnings found"
        fi
        return 0
    else
        echo "✗ Environment validation failed with $errors errors"
        return 1
    fi
}

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${0:t}" == "validate-environment.sh" ]]; then
    validate_test_environment
fi