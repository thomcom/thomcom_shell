#!/bin/bash
##############################################################################
# Thomcom Shell Test Suite Runner
# Runs all tests and reports results cleanly
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}🧪 Running: $test_name${NC}"
    ((TOTAL_TESTS++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        echo -e "${YELLOW}   Command: $test_command${NC}"
    fi
    echo
}

echo -e "${BLUE}🚀 Thomcom Shell Test Suite${NC}"
echo "==============================="
echo

# Test 1: Basic module structure
run_test "Module Structure" "ls -la core/ interactive/ tools/ features/ logging/ tests/"

# Test 2: Modular loading
run_test "Core Module Loading" "CLAUDECODE=1 zsh -c 'source ~/.zshrc && echo SUCCESS' 2>/dev/null"

# Test 3: Broadcast function availability 
run_test "Broadcast Function (CLAUDECODE)" "CLAUDECODE=1 zsh -c 'source ~/.zshrc && command -v zbc' 2>/dev/null"

# Test 4: Broadcast system functionality
run_test "Broadcast File Creation" "CLAUDECODE=1 zsh -c 'source ~/.zshrc && zbc \"echo test\" && ls ~/.zsh_broadcasts/broadcast_* | head -1' 2>/dev/null"

# Test 5: History system
run_test "History Configuration" "CLAUDECODE=1 zsh -c 'source ~/.zshrc && [[ -n \$HISTFILE ]]' 2>/dev/null"

# Test 6: Tool integrations
run_test "Tool Module Loading" "CLAUDECODE=1 zsh -c 'source ~/.zshrc && [[ -n \$NVM_DIR ]]' 2>/dev/null"

# Test 7: Docker environment test
if command -v docker >/dev/null; then
    echo -e "${BLUE}🐳 Running Docker Integration Test...${NC}"
    if ./tests/test_in_docker.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED: Docker Integration Test${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ FAILED: Docker Integration Test${NC}"
    fi
    ((TOTAL_TESTS++))
    echo
else
    echo -e "${YELLOW}⏭️  Skipping Docker test (docker not available)${NC}"
    echo
fi

# Test 8: Broadcast multi-session simulation
echo -e "${BLUE}🧪 Running: Multi-Session Broadcast Simulation${NC}"
((TOTAL_TESTS++))

# Create test broadcast
CLAUDECODE=1 zsh -c 'source ~/.zshrc && zbc "echo BROADCAST_TEST_$(date +%s) > /tmp/broadcast_test_result"' 2>/dev/null

# Simulate session processing broadcasts
CLAUDECODE=1 zsh -c '
source ~/.zshrc
# Simulate broadcast processing
for broadcast in ~/.zsh_broadcasts/broadcast_*; do
    [[ -f "$broadcast" ]] && source "$broadcast" 2>/dev/null || true
done
' 2>/dev/null

if [[ -f /tmp/broadcast_test_result ]]; then
    echo -e "${GREEN}✅ PASSED: Multi-Session Broadcast Simulation${NC}"
    ((PASSED_TESTS++))
    rm -f /tmp/broadcast_test_result
else
    echo -e "${RED}❌ FAILED: Multi-Session Broadcast Simulation${NC}"
fi
echo

# Summary
echo "==============================="
echo -e "${BLUE}📊 Test Results${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
    echo -e "\n${GREEN}🎉 All tests passed! Thomcom Shell is ready.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Check the issues above.${NC}"
    exit 1
fi