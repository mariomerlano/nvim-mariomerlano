# nvim-mariomerlano

A minimal yet powerful Neovim configuration with black background, zero distractions.

## Requirements

- Neovim >= 0.8.0
- Git (plugin management)
- Ripgrep (telescope grep)
- LSP servers: lua_ls, pyright, tsserver (npm i -g typescript-language-server), clangd

## Setup
```bash
ln -s ~/repos/nvim-mariomerlano/ ~/.config/nvim
```

## Features

- File explorer (NvimTree) 
- Fuzzy finder (Telescope)
- Git integration (Fugitive, Diffview)
- LSP support with minimal config
- No fancy icons, clean terminal-friendly UI

## Key Shortcuts

### General
- Space - Leader key
- Space+q - Quit
- Space+w - Copy file path
- Ctrl+h/j/k/l - Navigate windows
- Ctrl+arrows - Resize windows

### Files
- Space+e - Toggle explorer
- Ctrl+p - Find files
- Ctrl+f - Search in files

### Git
- Space+g - Toggle diff view
- Space+gh - File history
- Space+gf - Current file history

### LSP
- gd - Go to definition
- K - Documentation
- Space+lr - Rename
- Space+la - Code action

## License

MIT License - see [LICENSE](LICENSE) file
