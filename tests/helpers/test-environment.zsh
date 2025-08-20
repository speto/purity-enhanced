#!/usr/bin/env zsh
# Test environment setup helper
# This file should be sourced by all ZUnit test files to ensure consistent environment

# Determine test root directory dynamically
if [[ -n "$ZUNIT_TEST_ROOT" ]]; then
    TEST_ROOT="$ZUNIT_TEST_ROOT"
elif [[ -n "$BATS_TEST_DIRNAME" ]]; then
    TEST_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
else
    # Fallback: determine from the location of this script
    TEST_ROOT="$(cd "${0:A:h}/../.." && pwd)"
fi

# Ensure we have the correct theme file path
if [[ -n "$THEME_FILE" ]]; then
    PURITY_THEME_FILE="$THEME_FILE"
else
    PURITY_THEME_FILE="$TEST_ROOT/purity-enhanced.zsh"
fi

# Verify the theme file exists
if [[ ! -f "$PURITY_THEME_FILE" ]]; then
    echo "Error: Theme file not found at $PURITY_THEME_FILE" >&2
    return 1
fi

# Set up ZSH environment for testing
export FPATH="$TEST_ROOT:$FPATH"
export PATH="$TEST_ROOT:$PATH"

# Load the theme (safe loading with error handling)
load_purity_theme() {
    if [[ -f "$PURITY_THEME_FILE" ]]; then
        # Set required ZSH options for purity-enhanced.zsh to load properly
        setopt extended_glob null_glob prompt_subst
        source "$PURITY_THEME_FILE"
        return $?
    else
        echo "Error: Cannot load theme file: $PURITY_THEME_FILE" >&2
        return 1
    fi
}

# Test utilities for consistent loading
load_theme_safely() {
    if ! load_purity_theme; then
        echo "Failed to load purity-enhanced theme" >&2
        return 1
    fi
}

# Environment verification
verify_test_environment() {
    local errors=0
    
    if [[ ! -f "$PURITY_THEME_FILE" ]]; then
        echo "Error: Theme file missing: $PURITY_THEME_FILE" >&2
        ((errors++))
    fi
    
    if [[ ! -d "$TEST_ROOT" ]]; then
        echo "Error: Test root directory missing: $TEST_ROOT" >&2
        ((errors++))
    fi
    
    return $errors
}

# Export key variables for use in tests
export TEST_ROOT
export PURITY_THEME_FILE