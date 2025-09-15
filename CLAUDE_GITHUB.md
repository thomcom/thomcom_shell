# Open Source Repository Development Principles

## Core Philosophy

**Trust Legacy Principle**: Respect working code, replace broken scaffolding. When something works, don't fix it unless it's genuinely broken. When something doesn't work, replace it entirely with better contracts rather than patching.

**The Code Sells Itself**: Every badass GitHub project is a self-satirizing joke. Documentation and READMEs are noise - the code demonstrates value. Keep docs minimal, functional, and focused on the essential value proposition.

## README.md Structure (The Four Pillars)

1. **What this is** - One sentence describing the tool
2. **What problem it solves** - Why someone needs this  
3. **How to install it** - One command if possible
4. **Tutorial/Examples** - The most important use cases

No marketing fluff. No verbose architecture explanations. Show, don't tell.

## Repository Design

**Single Purpose**: Every repository is a tool that solves one problem. Every repository has a single purpose. Every repository is a tool that can be used by other tools, humans, and AI agents.

**API-Driven**: All repositories are self-documenting tools in the spirit of successful open source projects. Focus on clean interfaces and obvious usage patterns.

## Installation Philosophy

**One Command Setup**: `curl -fsSL [url] | bash` should give you a working system. No manual steps, no configuration files to edit, no "then do this" instructions.

**Complete Environment**: Don't just install the tool - install everything needed to use it effectively. Create a complete, isolated, working environment.

**Auto-Demonstration**: The installer should immediately show the user their new working system. Launch the tool at the end so they see instant results.

## Code Quality Standards

**No Hardcoded Paths**: Use `$HOME` and relative paths. Code must work for any user on any system.

**Location Agnostic**: Tools should work from any directory. Don't assume specific installation locations.

**Graceful Degradation**: Handle missing dependencies with helpful error messages. Provide manual fallback instructions.

**Test Everything**: Comprehensive test suites that validate the complete user experience, not just individual functions.

## User Experience

**Junior Developer Focus**: Design for people learning the tools, not experts. Provide safety nets, clear feedback, and educational value.

**Instant Gratification**: Users should see value within seconds of installation. Demonstrate the key features immediately.

**Error Recovery**: When things break, provide exact commands to fix them. Never leave users stranded.

## Configuration Strategy

**Sane Defaults**: The tool should work perfectly out of the box with zero configuration.

**Configurable When Needed**: Advanced users can customize, but beginners get a great experience immediately.

**Environment Isolation**: Never pollute the user's system. Use isolated environments (containers, virtual environments, etc.).

## Development Workflow

**Location-Agnostic Development**: The installer should work whether run via curl from the web or locally from within the repository.

**Modular Architecture**: Clean separation of concerns with obvious module boundaries and loading strategies.

**Context-Aware Loading**: Different features for different environments (interactive vs. non-interactive, human vs. AI).

## AI Integration

**Claude Code Ready**: Modern tools should work seamlessly with AI coding assistants. Provide CLAUDECODE modes that give AI agents full access to the environment without complex interactive features.

**Environment Sharing**: AI and human should share the same environment state and configuration.

## Key Lessons Learned

1. **PATH Management**: Always update PATH in the current session after installing tools
2. **Shell Compatibility**: Don't source ZSH configs from bash - detect and switch contexts appropriately  
3. **Signal Handling**: Some features (like broadcast systems) won't work in subprocess environments - design accordingly
4. **Package Managers**: Modern systems benefit from environment-first approaches (micromamba vs. system packages)
5. **User Paths**: Never hardcode user directories - everything must be portable

## The One-Command Promise

If you can't install and demonstrate your tool's core value with a single command, the tool isn't ready for open source. The installation experience IS the first impression of your software quality.

---

*These principles emerged from developing the thomcom shell - a modular ZSH configuration system that demonstrates broadcast commands, session logging, and AI integration in a single installation command.*