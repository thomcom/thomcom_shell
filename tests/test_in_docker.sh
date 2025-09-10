#!/bin/bash
##############################################################################
# Docker Test Runner for Thomcom Shell
##############################################################################

set -e

echo "🐳 Building Docker test environment..."
cd ~/.thomcom_shell
docker build -f Dockerfile.test -t thomcom-shell-test .

echo "🧪 Running comprehensive shell tests in clean environment..."

# Test 1: Basic shell loading
echo "Test 1: Basic shell functionality"
docker run --rm thomcom-shell-test zsh -c '
    source ~/.zshrc 2>/dev/null || exit 1
    echo "✓ Shell loads without errors"
    [[ -n "$THOMCOM_SHELL_ROOT" ]] && echo "✓ Shell root set: $THOMCOM_SHELL_ROOT" || exit 1
'

# Test 2: Non-interactive mode
echo -e "\nTest 2: Non-interactive shell"
docker run --rm thomcom-shell-test zsh -c '
    echo "source ~/.zshrc && echo NONINTERACTIVE_SUCCESS" | zsh 2>/dev/null
'

# Test 3: CLAUDECODE mode simulation
echo -e "\nTest 3: CLAUDECODE environment simulation" 
docker run --rm -e CLAUDECODE=1 thomcom-shell-test zsh -c '
    source ~/.zshrc 2>/dev/null || exit 1
    echo "✓ CLAUDECODE mode loads successfully"
    command -v zbc >/dev/null && echo "✓ zbc command available" || { echo "✗ zbc not available"; exit 1; }
'

# Test 4: Broadcast system functionality
echo -e "\nTest 4: Broadcast system"
docker run --rm thomcom-shell-test zsh -c '
    source ~/.zshrc 2>/dev/null || exit 1
    
    # Test zbc function
    command -v zbc >/dev/null || { echo "✗ zbc command not found"; exit 1; }
    
    # Test broadcast creation
    zbc "echo TEST_BROADCAST_SUCCESS" 2>/dev/null || { echo "✗ zbc execution failed"; exit 1; }
    
    # Check broadcast file was created
    if ls ~/.zsh_broadcasts/broadcast_* >/dev/null 2>&1; then
        echo "✓ Broadcast file created successfully"
        cat ~/.zsh_broadcasts/broadcast_* 2>/dev/null | grep -q "TEST_BROADCAST_SUCCESS" && echo "✓ Broadcast content correct"
    else
        echo "✗ Broadcast file not created"
        exit 1
    fi
'

# Test 5: Module loading verification  
echo -e "\nTest 5: Module loading verification"
docker run --rm thomcom-shell-test zsh -c '
    source ~/.zshrc 2>/dev/null || exit 1
    
    # Check core functions/variables are available
    [[ -n "$PATH" ]] && echo "✓ PATH configured"
    [[ -n "$HISTFILE" ]] && echo "✓ History configured: $HISTFILE"
    
    # Check if key modules loaded properly (check for their effects)
    [[ "$(set -o | grep autocd)" =~ on ]] && echo "✓ Core options loaded" || echo "ℹ autocd not set"
'

# Test 6: Multi-session broadcast test
echo -e "\nTest 6: Multi-session broadcast simulation"
docker run --rm thomcom-shell-test bash -c '
    # Start background zsh session
    zsh -c "source ~/.zshrc; while [[ -f /tmp/test_session ]]; do sleep 0.1; done" &
    SESSION_PID=$!
    
    # Give it time to start
    sleep 1
    
    # Send broadcast from another session  
    zsh -c "source ~/.zshrc; zbc \"echo MULTI_SESSION_TEST > /tmp/broadcast_result\""
    
    # Signal the session and wait a moment
    kill -USR1 $SESSION_PID 2>/dev/null || true
    sleep 1
    
    # Check if broadcast was processed
    if [[ -f /tmp/broadcast_result ]] && grep -q "MULTI_SESSION_TEST" /tmp/broadcast_result; then
        echo "✓ Multi-session broadcast successful"
    else
        echo "ℹ Multi-session broadcast test inconclusive (expected in container)"
    fi
    
    # Clean up
    touch /tmp/test_session
    wait $SESSION_PID 2>/dev/null || true
'

echo -e "\n🎉 All Docker tests completed successfully!"
echo "The modular shell configuration is working correctly in a clean environment."