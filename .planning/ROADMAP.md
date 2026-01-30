# Roadmap: .thomcom_shell bash Migration

**Created:** 2026-01-28
**Phases:** 4
**Core Value:** Universal, non-interruptive shell configuration

## Phase Overview

| # | Phase | Goal | Requirements |
|---|-------|------|--------------|
| 1 | Core Syntax Conversion | All zsh syntax -> bash syntax | CORE-01-04, SYN-01-04 |
| 2 | Signal & Hook Migration | Traps and PROMPT_COMMAND working | SIG-01-03, HOOK-01-03 |
| 3 | Installer Update | Install configures bash | INS-01-04 |
| 4 | Test & Verify | All tests pass under bash | TST-01-04 |

---

## Phase 1: Core Syntax Conversion

**Goal:** Convert all zsh-specific syntax to bash equivalents

**Requirements:** CORE-01, CORE-02, CORE-03, CORE-04, SYN-01, SYN-02, SYN-03, SYN-04

**Status:** Complete (2026-01-29)

**Plans:** 3 plans

Plans:
- [x] 01-01-PLAN.md - Convert core files and bashrc entry point
- [x] 01-02-PLAN.md - Convert complex tools (atuin, fzf, completion, broadcast)
- [x] 01-03-PLAN.md - Verify all syntax conversions

**Success Criteria:**
1. All `.zsh` files renamed to `.sh`
2. `zshrc` becomes `bashrc`
3. No `setopt` calls remain (converted to `shopt`)
4. No zsh-specific array syntax remains
5. Files parse without syntax errors under `bash -n`

**Files to modify:**
- `zshrc` -> `bashrc`
- `core/*.zsh` -> `core/*.sh`
- `tools/*.zsh` -> `tools/*.sh`
- `features/*.zsh` -> `features/*.sh`
- `interactive/*.zsh` -> `interactive/*.sh`
- `logging/*.zsh` -> `logging/*.sh`

---

## Phase 2: Signal & Hook Migration

**Goal:** Broadcast system and hooks work in bash

**Requirements:** SIG-01, SIG-02, SIG-03, HOOK-01, HOOK-02, HOOK-03

**Status:** Complete (2026-01-30)

**Plans:** 3 plans

Plans:
- [x] 02-01-PLAN.md - Enable signal handlers and PROMPT_COMMAND in broadcast.sh
- [x] 02-02-PLAN.md - Add incremental history via PROMPT_COMMAND
- [x] 02-03-PLAN.md - Verify Phase 2 completion

**Success Criteria:**
1. `zbc` command sends USR1 to all bash processes
2. Receiving shells execute broadcast commands
3. `PROMPT_COMMAND` updates prompt correctly
4. Exit cleanup runs via `trap ... EXIT`
5. No zsh trap syntax remains

**Key conversions:**
```bash
# zsh
TRAPUSR1() { _check_broadcasts; }
TRAPEXIT() { _cleanup; }

# bash
trap '_check_broadcasts' USR1
trap '_cleanup' EXIT
```

---

## Phase 3: Installer Update

**Goal:** Installer sets up bash, not zsh

**Requirements:** INS-01, INS-02, INS-03, INS-04

**Plans:** (created by /gsd:plan-phase)

**Success Criteria:**
1. `install.sh` links `~/.bashrc` not `~/.zshrc`
2. No `chsh` to zsh
3. No zsh installation step
4. Final `exec bash` instead of `exec zsh`
5. Documentation updated

---

## Phase 4: Test & Verify

**Goal:** All functionality verified under bash

**Requirements:** TST-01, TST-02, TST-03, TST-04

**Plans:** (created by /gsd:plan-phase)

**Success Criteria:**
1. `tests/test_suite.sh` runs under bash
2. All tests pass
3. `zbc "echo test"` broadcasts to other terminals
4. Session logging creates log files
5. Interactive features load correctly

---

## Dependencies

```
Phase 1 (syntax) ---+---> Phase 2 (signals)
                    |
                    +---> Phase 3 (installer)
                               |
Phase 2 --------------------+--+
                            |
                            v
                       Phase 4 (test)
```

Phases 2 and 3 can run in parallel after Phase 1.

---
*Roadmap created: 2026-01-28*
