# Requirements: .thomcom_shell bash Migration

**Defined:** 2026-01-28
**Core Value:** Universal, non-interruptive shell configuration

## v1 Requirements

### Core Migration

- [ ] **CORE-01**: All `.zsh` files renamed to `.sh`
- [ ] **CORE-02**: `zshrc` becomes `bashrc` with bash syntax
- [ ] **CORE-03**: `setopt` calls converted to `shopt` equivalents
- [ ] **CORE-04**: `[[ -o interactive ]]` → `[[ $- == *i* ]]`

### Signal Handlers

- [ ] **SIG-01**: `TRAPUSR1` → `trap '...' USR1`
- [ ] **SIG-02**: `TRAPEXIT` → `trap '...' EXIT`
- [ ] **SIG-03**: Broadcast system works with bash traps

### Hooks & Prompts

- [ ] **HOOK-01**: `precmd` → `PROMPT_COMMAND`
- [ ] **HOOK-02**: Prompt (PS1) works in bash
- [ ] **HOOK-03**: No zsh-specific prompt escapes

### Syntax Conversion

- [ ] **SYN-01**: zsh arrays → bash arrays
- [ ] **SYN-02**: `${(k)hash}` → `${!hash[@]}`
- [ ] **SYN-03**: `functions[name]` → `declare -f name`
- [ ] **SYN-04**: All zsh-specific expansions removed

### Installer

- [ ] **INS-01**: Installer configures bash, not zsh
- [ ] **INS-02**: Links `~/.bashrc` instead of `~/.zshrc`
- [ ] **INS-03**: Does not change default shell to zsh
- [ ] **INS-04**: Removes zsh installation step

### Testing

- [ ] **TST-01**: Test suite runs under bash
- [ ] **TST-02**: All tests pass
- [ ] **TST-03**: Broadcast system tested
- [ ] **TST-04**: Session logging tested

## Out of Scope

| Feature | Reason |
|---------|--------|
| Dual shell support | Clean break, no complexity |
| New features | Migration only |
| zsh compatibility layer | Defeats the purpose |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Pending |
| CORE-02 | Phase 1 | Pending |
| CORE-03 | Phase 1 | Pending |
| CORE-04 | Phase 1 | Pending |
| SIG-01 | Phase 2 | Pending |
| SIG-02 | Phase 2 | Pending |
| SIG-03 | Phase 2 | Pending |
| HOOK-01 | Phase 2 | Pending |
| HOOK-02 | Phase 2 | Pending |
| HOOK-03 | Phase 2 | Pending |
| SYN-01 | Phase 1 | Pending |
| SYN-02 | Phase 1 | Pending |
| SYN-03 | Phase 1 | Pending |
| SYN-04 | Phase 1 | Pending |
| INS-01 | Phase 3 | Pending |
| INS-02 | Phase 3 | Pending |
| INS-03 | Phase 3 | Pending |
| INS-04 | Phase 3 | Pending |
| TST-01 | Phase 4 | Pending |
| TST-02 | Phase 4 | Pending |
| TST-03 | Phase 4 | Pending |
| TST-04 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 22 total
- Mapped to phases: 22
- Unmapped: 0 ✓

---
*Requirements defined: 2026-01-28*
