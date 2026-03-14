# Testing ZSH Themes with zpty and Async Support

## Overview

This document explains how to test ZSH prompt themes that require interactive shell environments, particularly those using `zsh-async` for asynchronous operations. Traditional shell testing approaches fail with async callbacks because they require ZLE (ZSH Line Editor) to provide an event loop.

## The Problem with Traditional Testing

### Why Async Callbacks Don't Fire in Tests

ZSH async callbacks rely on **ZLE (ZSH Line Editor)** to provide an event loop that processes queued callbacks. ZLE is only active in:

- Interactive shells (`setopt INTERACTIVE`)  
- When ZLE is enabled (`setopt ZLE`)
- With a terminal attached (TTY)

Traditional test environments fail because:
```bash
# This won't work for async callbacks
zsh -c "source theme.zsh && trigger_async_operation"
```

The async operation queues but callbacks never fire because there's no ZLE event loop.

## The zpty Solution

### What is zpty?

`zpty` is a ZSH module that creates **pseudo-terminals** - virtual terminal sessions that:
- Run interactive ZSH instances
- Enable ZLE automatically
- Provide proper event loops for async callbacks
- Allow programmatic interaction with shell sessions

### How zsh-async Tests Itself

The `zsh-async` library uses zpty for its own testing:
```zsh
# Start interactive session
zpty -b test_session zsh -i

# Send commands
zpty -w test_session "async_start_worker test_worker"

# Read results
zpty -rt test_session output 5
```

## Our Testing Infrastructure

### Helper Functions

The `tests/helpers/zpty-test-helper.zsh` provides:

#### Session Management
```zsh
# Start interactive session with ZLE and async support
zpty_start_session "session_name"

# Clean up session
zpty_cleanup_session "session_name"
```

#### Command Execution
```zsh
# Send command and wait for completion
zpty_execute_and_wait "session_name" "git status"

# Send command without waiting
zpty_send_command "session_name" "echo 'test'"

# Read output with timeout
output=$(zpty_read_output "session_name" 5)
```

#### Theme Testing
```zsh
# Load theme in interactive environment
zpty_load_theme "session_name"

# Test async operations
zpty_test_async_operations "session_name" 3
```

#### Environment Validation
```zsh
# Check if ZLE is active
zpty_check_zle "session_name"

# Check if async functions are available
zpty_check_async "session_name"
```

### Test Structure

Integration tests using zpty follow this pattern:

```zsh
@test 'async git operations work with ZLE' {
    local session="test_async_$$"
    
    # Start session
    run zpty_start_session "$session"
    assert $state equals 0
    
    # Load theme
    run zpty_load_theme "$session"
    assert $state equals 0
    
    # Setup git repository
    run zpty_setup_git_repo "$session" "/tmp/test_repo"
    assert $state equals 0
    
    # Test async operations
    run zpty_test_async_operations "$session" 5
    assert $state equals 0
    
    # Verify results
    zpty_send_command "$session" "git_prompt_info"
    local output=$(zpty_read_output "$session")
    assert "$output" is_not_empty
    
    # Clean up
    zpty_cleanup_session "$session"
}
```

## Key Testing Concepts

### Session Lifecycle

1. **Start** - Create interactive zpty session
2. **Setup** - Load theme and configure environment  
3. **Execute** - Run commands and trigger async operations
4. **Wait** - Allow async callbacks to complete
5. **Verify** - Check results and outputs
6. **Cleanup** - Destroy session and temp files

### Async Testing Patterns

#### Testing Worktree Detection
```zsh
# Create worktree
zpty_execute_and_wait "$session" "git worktree add -b feature ../feature"

# Change to worktree
zpty_execute_and_wait "$session" "cd ../feature"

# Trigger async detection
run zpty_test_async_operations "$session" 5

# Verify worktree was detected
zpty_send_command "$session" "echo \${prompt_purity_enhanced_vcs_info[worktree]}"
local result=$(zpty_read_output "$session")
assert "$result" contains "feature"
```

#### Testing Directory Changes
```zsh
# Start in repo1
zpty_execute_and_wait "$session" "cd '$repo1'"
run zpty_test_async_operations "$session" 3

# Change to repo2
zpty_execute_and_wait "$session" "cd '$repo2'" 
run zpty_test_async_operations "$session" 3

# Verify async worker updated
zpty_send_command "$session" "git_prompt_info"
local output=$(zpty_read_output "$session")
assert "$output" contains "repo2_branch"
```

### Error Handling

#### Timeout Management
```zsh
# Set custom timeout for slow operations
zpty_test_async_operations "$session" 10

# Handle timeouts gracefully
if ! zpty_wait_for_prompt "$session" 5; then
    echo "Operation timed out - this is expected for this test"
fi
```

#### Session Recovery
```zsh
# Test continues even if async worker crashes
zpty_send_command "$session" "async_worker_eval 'worker' 'exit 1'"
sleep 2

# Verify session recovers
zpty_execute_and_wait "$session" "prompt_purity_enhanced_precmd"
run zpty_test_async_operations "$session" 3
assert $state equals 0
```

## Environment Requirements

### Docker Environment
Our tests run in Docker with:
- Ubuntu 22.04 base
- ZSH with zpty module
- zsh-async in `/usr/share/zsh/site-functions/`
- Interactive terminal support

### Validation Checks
The environment validator checks:
- zpty module availability
- ZLE status (when applicable)  
- zsh-async presence
- Basic zpty functionality

## Best Practices

### Do's
✅ Always clean up zpty sessions in teardown  
✅ Use unique session names with `$$` to avoid conflicts  
✅ Validate environment before running zpty tests  
✅ Set appropriate timeouts for async operations  
✅ Test both success and failure scenarios  

### Don'ts  
❌ Don't rely on async callbacks in non-interactive tests  
❌ Don't use script-based wrappers for ZLE testing  
❌ Don't assume async operations complete immediately  
❌ Don't forget to test error recovery scenarios  
❌ Don't leave zpty sessions running after tests  

## Debugging

### Enable Debug Output
```bash
export ZPTY_TEST_DEBUG=1
make test
```

### Manual Testing
```bash
# Start Docker test environment
make test-dev

# Inside container:
source tests/helpers/zpty-test-helper.zsh
zpty_start_session "debug"
zpty_load_theme "debug"
# ... interactive testing
```

### Common Issues

#### "zpty module not available"
```bash
# In zsh
zmodload zsh/zpty
```

#### "ZLE not active"  
Only occurs in interactive shells - expected in test runner.

#### "Async callbacks not firing"
Verify ZLE is active with `[[ -o zle ]]` in the zpty session.

## Performance Considerations

- zpty sessions have startup overhead (~100-200ms)
- Async operations typically complete within 1-3 seconds
- Use timeouts to prevent hanging tests
- Clean up promptly to free resources

## Comparison with Other Approaches

| Method | ZLE Support | Async Support | Complexity | Reliability |
|--------|-------------|---------------|------------|-------------|
| `zpty` | ✅ Full | ✅ Full | Medium | High |
| `script` | ❌ Limited | ❌ None | High | Low |
| Direct execution | ❌ None | ❌ None | Low | Low |
| expect/pexpect | ✅ Full | ✅ Full | High | Medium |

## Conclusion

Using zpty for testing interactive ZSH themes provides the most accurate testing environment, ensuring that async operations work exactly as they do in real user environments. This approach catches issues that traditional testing methods miss, leading to more reliable prompt themes.