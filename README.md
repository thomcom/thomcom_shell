# Thomcom Shell Configuration

A beautifully modular, context-aware ZSH configuration system that adapts to different environments and use cases.

## Features

🚀 **Context-Aware Loading** - Different modules load based on shell type (interactive, non-interactive, CLAUDECODE)  
📡 **Broadcast System** - Send commands to all active zsh sessions simultaneously  
📝 **Session Logging** - Automatic terminal session recording with workspace awareness  
🔧 **Tool Integration** - Seamless integration with NVM, Conda, FZF, Kubernetes, and more  
🎨 **Clean Architecture** - Modular design with clear separation of concerns  

## Architecture

```
.thomcom_shell/
├── zshrc                    # Main orchestrator
├── core/                    # Essential settings (always loaded)
│   ├── environment.zsh      # PATH, exports, variables
│   ├── history.zsh          # Advanced history management
│   └── options.zsh          # Basic zsh options
├── interactive/             # Interactive shell features
│   ├── prompt.zsh          # Terminal prompt
│   ├── aliases.zsh         # Command shortcuts
│   ├── completion.zsh      # Tab completion
│   └── colors.zsh          # Color configuration
├── logging/                 # Session recording
│   ├── session-tracker.zsh # Automatic session logging
│   └── replay-tools.zsh    # Session replay functions
├── tools/                   # Tool integrations
│   ├── nvm.zsh             # Node version management
│   ├── conda.zsh           # Python environment management
│   ├── fzf.zsh            # Fuzzy finding
│   └── system.zsh         # System tweaks
└── features/
    └── broadcast.zsh       # Multi-session broadcasting
```

## Loading Strategy

1. **All Shells**: `core/` + `tools/` + `features/`
2. **CLAUDECODE=1**: Core functionality without logging or interactive features
3. **Interactive**: Full feature set including prompt, aliases, completions
4. **Session Logging**: Automatic recording for workspace-aware terminals

## Broadcast System

Send commands to all active zsh sessions:

```bash
zbc "export API_KEY=xyz123"        # Set environment variable everywhere
zbc "source ~/.zshrc"              # Reload configs in all sessions
zbc "cd ~/project && git pull"     # Change directory and pull updates
```

## Installation

This configuration is symlinked to `~/.zshrc` and managed as a git repository for version control and easy updates.

## Work-Specific Configuration

Sensitive or company-specific configurations are loaded from `~/.nvidia/work.zsh` if available, keeping the main configuration clean and shareable.