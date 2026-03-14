# Interactive Testing Analysis for Prompt Themes

## Problem Statement

Testing a ZSH prompt theme requires an **interactive shell environment** with proper pseudo-terminal (PTY) support to enable:
- ZSH Line Editor (ZLE) functionality
- Async callback mechanisms via ZLE watchers
- Real terminal-like behavior for prompt rendering

However, automated tests typically run in **non-interactive** environments, causing async functionality to fail and producing false negatives.

## Solution Analysis

### Option A: `script` Command Wrapper

**Approach**: Wrap test execution in `script` command to create PTY environment.

```bash
script -qec "zsh -i -c 'source theme; run_tests'" /dev/null
```

**Pros:**
- ✅ **Minimal implementation** - One wrapper script, no infrastructure changes
- ✅ **Battle-tested** - Standard Unix utility since 1979
- ✅ **CI/Docker friendly** - Available in all standard Unix environments
- ✅ **Zero learning curve** - Team already understands `script`
- ✅ **Transparent** - Tests run unmodified, just wrapped in PTY

**Cons:**
- ❌ **Limited control** - Cannot interact programmatically during test execution
- ❌ **Platform variations** - BSD vs GNU `script` have different flags
- ❌ **Output noise** - Terminal escape sequences may pollute output
- ❌ **Basic timing** - Relies on sleep/timeouts for async coordination

### Option B: `zpty` Module Approach

**Approach**: Use ZSH's built-in PTY module for programmatic control.

```zsh
zmodload zsh/zpty
zpty -b test_session "zsh -i"
zpty -w test_session "source theme"
zpty -r test_session output
```

**Pros:**
- ✅ **Full control** - Send input, read output, control timing precisely
- ✅ **Native ZSH** - No external dependencies beyond ZSH
- ✅ **Clean output** - Programmatic filtering of terminal sequences
- ✅ **Interactive simulation** - Can simulate complex user interactions
- ✅ **Async-aware** - Wait for specific output patterns or timeouts

**Cons:**
- ❌ **High complexity** - Requires complete test infrastructure rewrite
- ❌ **Fragile** - PTY handling is notoriously difficult to get right
- ❌ **Debug difficulty** - PTY issues are hard to diagnose and fix
- ❌ **Team expertise** - Requires PTY programming knowledge

### Option C: `expect` Approach

**Approach**: Use TCL expect for interactive automation.

```tcl
spawn zsh -i
expect "❯"
send "source theme\r"
expect "❯"
```

**Pros:**
- ✅ **Purpose-built** - Expect was designed specifically for interactive testing
- ✅ **Robust patterns** - Advanced timeout and pattern matching capabilities
- ✅ **Mature ecosystem** - 30+ years of interactive testing patterns and best practices

**Cons:**
- ❌ **Language mismatch** - TCL scripting for ZSH tests creates impedance
- ❌ **External dependency** - Must install and maintain expect package
- ❌ **Process overhead** - Spawning TCL interpreter adds complexity

## Decision Matrix

| Criteria | `script` | `zpty` | `expect` |
|----------|----------|---------|----------|
| Implementation effort | **1 hour** | 2-3 days | 1 day |
| Maintenance burden | **Low** | High | Medium |
| Team familiarity | **High** | Low | Low |
| Debugging ease | **Medium** | Hard | Medium |
| Test reliability | Medium | High* | High |
| CI compatibility | **High** | High | Medium |
| Feature completeness | Basic | **Full** | Full |

*If implemented correctly

## Engineering Decision: Option A

### Rationale

Following Kent Beck's principle: **"Make it work, make it right, make it fast"**

1. **Make it work** → `script` approach (immediate value)
2. **Make it right** → `zpty` approach (if proven necessary)
3. **Make it fast** → Optimization (likely never needed)

### Key Decision Factors

**Pragmatism Over Perfection**: We have users experiencing bugs now. A working test in 1 hour is better than a perfect test in 3 days.

**YAGNI Principle**: You Aren't Gonna Need It. Most prompt testing scenarios don't require fine-grained PTY control. Build for current needs, not hypothetical future requirements.

**Team Velocity**: Every team member understands `script`. Zero training required, minimal documentation needed, junior developers can maintain it.

**Risk Management**: `script` is low-risk with known failure modes. `zpty` has complex failure cases that are hard to diagnose.

### Upgrade Path

Start with `script` for immediate testing capabilities. Migrate to `zpty` **only if** we encounter specific limitations:
- Need multi-step interactive dialogs
- Require precise async timing control
- Must parse complex prompt output programmatically

Most prompt themes will never need these advanced features.

## Implementation Strategy

### Phase 1: Interactive Wrapper (Today)

```bash
# tests/helpers/interactive-wrapper.sh
#!/bin/bash
if [ -t 0 ]; then
    # Already interactive
    exec "$@"
else
    # Wrap in PTY
    script -qec "$*" /dev/null
fi
```

### Phase 2: ZSH Helper Functions

```zsh
# tests/helpers/interactive-test.zsh
run_interactive_test() {
    local test_script="$1"
    local timeout="${2:-5}"
    
    local test_file=$(mktemp)
    echo "$test_script" > "$test_file"
    
    timeout "$timeout" tests/helpers/interactive-wrapper.sh zsh "$test_file"
    local result=$?
    rm -f "$test_file"
    return $result
}
```

### Phase 3: Integration Test Updates

```zsh
@test 'Async worktree detection' {
    run_interactive_test '
        source theme
        cd worktree
        sleep 1  # Wait for async
        [[ "$PROMPT" == *"🌿"* ]] || exit 1
    '
    assert $? equals 0
}
```

## Expected Outcomes

1. **Immediate**: Tests run in proper interactive environment
2. **Short-term**: Async functionality works in tests
3. **Long-term**: True validation of interactive prompt behavior

## Success Metrics

- Integration tests pass consistently
- Async callbacks fire in test environment  
- No false negatives from non-interactive environment
- Team can debug prompt issues effectively

This approach prioritizes shipping working tests quickly while maintaining the option to upgrade to more sophisticated PTY control if business needs evolve.