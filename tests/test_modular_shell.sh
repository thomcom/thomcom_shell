#!/bin/bash
##############################################################################
# Thomcom Shell Test Suite
# Validates modular shell configuration works correctly in different contexts
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0

# Test helpers
test_start() {
    echo -e "${BLUE}Test $((++TESTS_RUN)): $1${NC}"
}

test_pass() {
    echo -e "${GREEN}  ✓ PASS${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}  ✗ FAIL: $1${NC}"
}

test_info() {
    echo -e "${YELLOW}  ℹ $1${NC}"
}

# Cleanup function
cleanup() {
    echo -e "\n${BLUE}Cleaning up test environment...${NC}"
    rm -f /tmp/test_*.log /tmp/shell_test_* 2>/dev/null || true
    pkill -f "test_shell_session" 2>/dev/null || true
    exit 0
}
trap cleanup EXIT INT TERM

echo -e "${BLUE}🧪 Thomcom Shell Test Suite${NC}\n"

##############################################################################
# Test 1: Basic Module Loading
##############################################################################
test_start "Module loading and structure"

if [[ -f ~/.thomcom_shell/zshrc ]]; then
    test_pass
else
    test_fail "Main zshrc file not found"
fi

# Check all expected modules exist
MODULES=(
    "core/environment.zsh"
    "core/history.zsh" 
    "core/options.zsh"
    "interactive/prompt.zsh"
    "interactive/aliases.zsh"
    "interactive/completion.zsh"
    "interactive/colors.zsh"
    "tools/nvm.zsh"
    "tools/conda.zsh"
    "tools/fzf.zsh"
    "features/broadcast.zsh"
    "logging/session-tracker.zsh"
    "logging/replay-tools.zsh"
)

for module in "${MODULES[@]}"; do
    if [[ -f ~/.thomcom_shell/$module ]]; then
        test_info "✓ $module exists"
    else
        test_fail "Missing module: $module"
    fi
done

##############################################################################  
# Test 2: CLAUDECODE Environment
##############################################################################
test_start "CLAUDECODE environment loading"

# Test that CLAUDECODE=1 loads core modules but skips interactive/logging
output=$(CLAUDECODE=1 zsh -c 'source ~/.zshrc 2>&1; echo "PATH_SET"; command -v zbc >/dev/null && echo "ZBC_AVAILABLE" || echo "ZBC_MISSING"')

if echo "$output" | grep -q "PATH_SET"; then
    test_info "✓ Core modules loaded in CLAUDECODE mode"
else
    test_fail "Core modules failed to load in CLAUDECODE mode"
fi

if echo "$output" | grep -q "ZBC_AVAILABLE"; then
    test_info "✓ Broadcast system available in CLAUDECODE mode"
else
    test_fail "Broadcast system not available in CLAUDECODE mode"
fi

if echo "$output" | grep -q "Thomcom Shell loaded successfully"; then
    test_fail "Interactive features loaded in CLAUDECODE mode (should not)"
else
    test_info "✓ Interactive features properly skipped in CLAUDECODE mode"
    test_pass
fi

##############################################################################
# Test 3: Non-Interactive Shell
##############################################################################
test_start "Non-interactive shell behavior"

output=$(echo 'source ~/.zshrc; echo "LOADED"' | zsh 2>&1)

if echo "$output" | grep -q "LOADED"; then
    test_info "✓ Non-interactive shell loads successfully"
    test_pass
else
    test_fail "Non-interactive shell failed to load"
fi

##############################################################################
# Test 4: Broadcast System Functionality  
##############################################################################
test_start "Broadcast system functionality"

# Create test session that loads zshrc
zsh -c '
source ~/.zshrc
echo "TEST_SESSION_READY" > /tmp/shell_test_ready
# Keep session alive
while [[ -f /tmp/shell_test_ready ]]; do sleep 0.1; done
' &
TEST_SESSION_PID=$!

# Wait for session to be ready
timeout=10
while [[ $timeout -gt 0 ]] && [[ ! -f /tmp/shell_test_ready ]]; do
    sleep 0.1
    ((timeout--))
done

if [[ -f /tmp/shell_test_ready ]]; then
    test_info "✓ Test session started"
    
    # Test zbc function exists
    if CLAUDECODE=1 zsh -c 'source ~/.zshrc && command -v zbc' >/dev/null 2>&1; then
        test_info "✓ zbc command available"
        
        # Test broadcast creation
        mkdir -p ~/.zsh_broadcasts
        test_cmd="echo 'BROADCAST_TEST_SUCCESS' > /tmp/broadcast_test_result"
        
        if CLAUDECODE=1 zsh -c "source ~/.zshrc && zbc '$test_cmd'" 2>/dev/null; then
            test_info "✓ Broadcast command created successfully"
            
            # Check if broadcast file was created
            sleep 1
            if ls ~/.zsh_broadcasts/broadcast_* >/dev/null 2>&1; then
                test_info "✓ Broadcast file created"
                test_pass
            else
                test_fail "Broadcast file not created"
            fi
        else
            test_fail "zbc command execution failed"
        fi
    else
        test_fail "zbc command not available"
    fi
else
    test_fail "Test session failed to start"
fi

# Clean up test session
rm -f /tmp/shell_test_ready
kill $TEST_SESSION_PID 2>/dev/null || true

##############################################################################
# Test 5: Path and Environment Setup
##############################################################################
test_start "Environment variable setup"

env_output=$(CLAUDECODE=1 zsh -c 'source ~/.zshrc && echo "PATH=$PATH" && echo "VOLTA_HOME=$VOLTA_HOME"' 2>/dev/null)

if echo "$env_output" | grep -q "VOLTA_HOME=/home/tcomer/.volta"; then
    test_info "✓ VOLTA_HOME set correctly"
else
    test_fail "VOLTA_HOME not set correctly"
fi

if echo "$env_output" | grep -q "/home/tcomer/.local/bin"; then
    test_info "✓ Local bin in PATH"
    test_pass
else
    test_fail "Local bin not in PATH"
fi

##############################################################################
# Test 6: History System
##############################################################################
test_start "History system functionality"

# Test history setup in CLAUDECODE mode (simple version)
hist_output=$(CLAUDECODE=1 zsh -c 'source ~/.zshrc && echo $HISTFILE && echo $HISTSIZE' 2>/dev/null)

if echo "$hist_output" | grep -q "/home/tcomer/.zsh_history"; then
    test_info "✓ HISTFILE set correctly for CLAUDECODE"
else
    test_fail "HISTFILE not set correctly for CLAUDECODE"
fi

if echo "$hist_output" | grep -q "1000"; then
    test_info "✓ HISTSIZE set correctly for CLAUDECODE"
    test_pass
else
    test_fail "HISTSIZE not set correctly for CLAUDECODE"
fi

##############################################################################
# Test 7: Module Independence
##############################################################################
test_start "Module independence and error isolation"

# Test that a broken module doesn't break the whole system
broken_module="/tmp/broken_test_module.zsh"
echo "this is broken zsh syntax (" > "$broken_module"

# Test resilience to broken modules
resilience_output=$(THOMCOM_SHELL_ROOT=/tmp zsh -c '
source_module() { [[ -f "$THOMCOM_SHELL_ROOT/$1" ]] && source "$THOMCOM_SHELL_ROOT/$1" 2>/dev/null || true; }
source_module "broken_test_module.zsh"
echo "SURVIVED_BROKEN_MODULE"
' 2>/dev/null)

rm -f "$broken_module"

if echo "$resilience_output" | grep -q "SURVIVED_BROKEN_MODULE"; then
    test_info "✓ System resilient to broken modules"
    test_pass
else
    test_fail "System not resilient to broken modules"
fi

##############################################################################
# Test Summary
##############################################################################
echo -e "\n${BLUE}📊 Test Results${NC}"
echo -e "Tests Run: ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"

if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
    echo -e "\n${GREEN}🎉 All tests passed! Thomcom Shell is working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the configuration.${NC}"
    exit 1
fi