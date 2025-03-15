# Neovim Configuration Guide

## Commands
- `:Lazy` - Open Lazy.nvim plugin manager
- `:checkhealth` - Run Neovim health checks
- `:LspInfo` - Show LSP server status
- `:Mason` - Open Mason package manager
- `:Telescope` - Open fuzzy finder

## Code Style
- **Indentation**: 2 spaces (not tabs)
- **Naming**: Use camelCase for variables and functions
- **Functions**: Prefer local functions with explicit return types
- **Tables**: Use `=` for key assignments in tables
- **Modules**: Follow Lua module pattern with return at end
- **Comments**: Use -- for single line, --[[ ]] for multiline
- **Imports**: Group by built-in, then plugins, then local modules

## Structure
- `init.lua` - Main entry point
- `lua/config/` - Core configuration files
- `lua/plugins/` - Plugin specifications for Lazy.nvim

## Best Practices
- Prefer explicit nil checks over falsy checks
- Use pcall for error handling
- Keep plugin configurations modular
- Document complex configurations with comments