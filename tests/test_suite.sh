#!/bin/bash
##############################################################################
# thomcom Shell Validation - Tier-aware test suite
##############################################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}  ✓ $1${NC}"; ((PASS++)); }
fail() { echo -e "${RED}  ✗ $1${NC}"; ((FAIL++)); }

SHELL_ROOT="${HOME}/.thomcom_shell"

echo -e "${BLUE}🧪 thomcom Shell Tests${NC}\n"

# Determine tier
if [[ -f "$SHELL_ROOT/.tier" ]]; then
    TIER="$(< "$SHELL_ROOT/.tier")"
    TIER="${TIER%$'\n'}"
else
    TIER="full"
fi
echo -e "Tier: ${TIER}\n"

# Test 1: VERSION file
echo "Test 1: VERSION file"
if [[ -f "$SHELL_ROOT/VERSION" ]]; then
    VER="$(< "$SHELL_ROOT/VERSION")"
    pass "VERSION exists: ${VER%$'\n'}"
else
    fail "VERSION file missing"
fi

# Test 2: Core files exist (all tiers)
echo -e "\nTest 2: Core files exist"
for module in bashrc core/environment.sh core/options.sh core/history.sh \
    interactive/aliases-base.sh interactive/colors.sh interactive/prompt.sh \
    interactive/completion.sh tools/fzf.sh tools/conda.sh; do
    if [[ -f "$SHELL_ROOT/$module" ]]; then
        pass "$module"
    else
        fail "$module missing"
    fi
done

# Test 3: Shell tier files (shell + full)
if [[ "$TIER" == "shell" || "$TIER" == "full" ]]; then
    echo -e "\nTest 3: Shell tier files"
    for module in tools/atuin.sh tools/nvm.sh interactive/aliases.sh; do
        if [[ -f "$SHELL_ROOT/$module" ]]; then
            pass "$module"
        else
            fail "$module missing"
        fi
    done
fi

# Test 4: Full tier files
if [[ "$TIER" == "full" ]]; then
    echo -e "\nTest 4: Full tier files"
    for module in features/broadcast.sh logging/session-tracker.sh \
        logging/replay-tools.sh tools/system.sh; do
        if [[ -f "$SHELL_ROOT/$module" ]]; then
            pass "$module"
        else
            fail "$module missing"
        fi
    done
fi

# Test 5: No kitty references in shell configs
echo -e "\nTest 5: No kitty references"
if grep -r --include='*.sh' --include='*.bash' 'kitty' "$SHELL_ROOT"/{core,tools,features,interactive,logging}/ 2>/dev/null | grep -v '\.bak' | grep -q .; then
    fail "kitty references found in shell configs"
else
    pass "No kitty references in shell configs"
fi

# Test 6: CLAUDECODE compatibility
echo -e "\nTest 6: CLAUDECODE compatibility"
if timeout 5s bash -c "CLAUDECODE=1 source $SHELL_ROOT/bashrc >/dev/null 2>&1"; then
    pass "CLAUDECODE mode loads without errors"
else
    fail "CLAUDECODE mode fails"
fi

# Test 7: Tier variable exported
echo -e "\nTest 7: Tier variable"
output=$(timeout 5s bash -c "CLAUDECODE=1 source $SHELL_ROOT/bashrc >/dev/null 2>&1 && echo \$THOMCOM_TIER")
if [[ "$output" == "$TIER" ]]; then
    pass "THOMCOM_TIER=$output"
else
    fail "THOMCOM_TIER expected '$TIER' got '$output'"
fi

# Test 8: Version variable exported
echo -e "\nTest 8: Version variable"
output=$(timeout 5s bash -c "CLAUDECODE=1 source $SHELL_ROOT/bashrc >/dev/null 2>&1 && echo \$THOMCOM_SHELL_VERSION")
if [[ -n "$output" ]]; then
    pass "THOMCOM_SHELL_VERSION=$output"
else
    fail "THOMCOM_SHELL_VERSION not set"
fi

# Test 9: Broadcast function (full tier)
if [[ "$TIER" == "full" ]]; then
    echo -e "\nTest 9: Broadcast system"
    if timeout 5s bash -c "CLAUDECODE=1 source $SHELL_ROOT/bashrc >/dev/null 2>&1 && command -v zbc >/dev/null"; then
        pass "zbc command available"
    else
        fail "zbc command missing"
    fi
fi

# Test 10: install.sh argument parsing
echo -e "\nTest 10: Installer"
if bash "$SHELL_ROOT/install.sh" --help 2>&1 | grep -q 'tier'; then
    pass "install.sh --help mentions tier"
else
    fail "install.sh --help broken"
fi

# Test 11: Dockerfile exists
echo -e "\nTest 11: Docker support"
if [[ -f "$SHELL_ROOT/Dockerfile" ]]; then
    pass "Dockerfile exists"
else
    fail "Dockerfile missing"
fi

# Summary
echo -e "\n${BLUE}📊 Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
[[ $FAIL -eq 0 ]]
