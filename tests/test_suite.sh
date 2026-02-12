#!/bin/bash
##############################################################################
# Quick thomcom Shell Validation - Simple tests that actually work
##############################################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧪 Quick thomcom Shell Tests${NC}\n"

# Test 1: Basic files exist
echo "Test 1: Core files exist"
if [[ -f ~/.thomcom_shell/bashrc ]]; then
    echo -e "${GREEN}  ✓ SUCCESS: Main bashrc exists${NC}"
else
    echo -e "${RED}  ✗ FAIL: Main bashrc missing${NC}"
fi

# Test 2: CLAUDECODE compatibility
echo -e "\nTest 2: CLAUDECODE compatibility"
if timeout 5s bash -c 'CLAUDECODE=1 source ~/.thomcom_shell/bashrc >/dev/null 2>&1'; then
    echo -e "${GREEN}  ✓ SUCCESS: CLAUDECODE mode loads without errors${NC}"
else
    echo -e "${RED}  ✗ FAIL: CLAUDECODE mode fails${NC}"
fi

# Test 3: Broadcast function available
echo -e "\nTest 3: Broadcast system"
if timeout 5s bash -c 'CLAUDECODE=1 source ~/.thomcom_shell/bashrc >/dev/null 2>&1 && command -v zbc >/dev/null'; then
    echo -e "${GREEN}  ✓ SUCCESS: zbc command available${NC}"
else
    echo -e "${RED}  ✗ FAIL: zbc command missing${NC}"
fi

# Test 4: Environment variables
echo -e "\nTest 4: Environment setup"
output=$(timeout 5s bash -c 'CLAUDECODE=1 source ~/.thomcom_shell/bashrc >/dev/null 2>&1 && echo "$THOMCOM_SECRETS_DIR"')
if [[ "$output" == *".nvidia"* ]]; then
    echo -e "${GREEN}  ✓ SUCCESS: THOMCOM_SECRETS_DIR configured (${output})${NC}"
else
    echo -e "${RED}  ✗ FAIL: THOMCOM_SECRETS_DIR not set properly (got: ${output})${NC}"
fi

# Test 5: FZF integration
echo -e "\nTest 5: FZF integration"
if timeout 5s bash -c 'source ~/.thomcom_shell/bashrc >/dev/null 2>&1 && command -v fzf >/dev/null'; then
    echo -e "${GREEN}  ✓ SUCCESS: FZF command available${NC}"
else
    echo -e "${RED}  ✗ FAIL: FZF not available${NC}"
fi

# Test 6: Tool modules load
echo -e "\nTest 6: Core modules exist"
missing_count=0
for module in core/environment.sh tools/fzf.sh features/broadcast.sh; do
    if [[ ! -f ~/.thomcom_shell/$module ]]; then
        ((missing_count++))
    fi
done

if [[ $missing_count -eq 0 ]]; then
    echo -e "${GREEN}  ✓ SUCCESS: All core modules present${NC}"
else
    echo -e "${RED}  ✗ FAIL: $missing_count modules missing${NC}"
fi

echo -e "\n${BLUE}📊 Quick validation complete!${NC}"
