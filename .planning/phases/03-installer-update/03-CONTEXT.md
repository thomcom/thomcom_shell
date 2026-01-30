# Phase 3: Installer Update - Context

**Gathered:** 2026-01-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Modify install.sh to configure bash instead of zsh. This includes: removing zsh installation/checks, linking ~/.bashrc instead of ~/.zshrc, removing chsh to zsh, updating directory names, and final `exec bash` instead of `exec zsh`.

</domain>

<decisions>
## Implementation Decisions

### Shell references
- Replace all "zsh" references with "bash" (comments, messages, checks)
- Remove zsh installation step entirely (bash is always available)
- Remove chsh call (don't change user's default shell)
- Final exec should be `exec bash` not `exec zsh`

### Config file handling
- Link `~/.bashrc` instead of `~/.zshrc`
- Backup existing `~/.bashrc` to `~/.bashrc.backup`
- Source `bashrc` (not `zshrc`) in the final exec

### Directory naming
- Rename `~/.zsh_broadcasts` to `~/.bash_broadcasts` in mkdir call
- Update broadcast.sh to match (already uses ~/.bash_broadcasts from Phase 1)

### Work secrets template
- Update template file from `work.zsh` to `work.sh`
- Update shebang from `#!/bin/zsh` to `#!/bin/bash`
- Keep content structure the same

### History import
- Check for `.bash_history` instead of `.zsh_history`
- Atuin can import from either — use `atuin import auto` (unchanged)

### Claude's Discretion
- Exact wording of status messages
- Whether to add any bash-specific checks

</decisions>

<specifics>
## Specific Ideas

No specific requirements — mechanical substitution of zsh references to bash equivalents.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-installer-update*
*Context gathered: 2026-01-30*
