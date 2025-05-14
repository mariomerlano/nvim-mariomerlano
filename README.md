# nvim-mariomerlano

A simple yet powerful Neovim configuration with black background, zero distractions.

## Requirements

- Neovim >= 0.8.0
- Git (plugin management)
- Ripgrep (telescope grep)
- LSP servers: 
  - lua_ls
  - pyright
  - tsserver (`npm i -g typescript-language-server`)
  - clangd

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
- `Space` - Leader key
- `Space+q` - Quit
- `Space+w` - Copy file path

### Window Navigation
- `Ctrl+h/j/k/l` - Navigate windows (left/down/up/right)
- `Ctrl+arrows` - Resize windows

### Files
- `Space+e` - Toggle file explorer
- `Ctrl+p` - Find files
- `Ctrl+f` - Search in files

### Buffer Navigation
- `Shift+h` - Previous buffer
- `Shift+l` - Next buffer

### Git
- `Space+g` - Toggle diff view
- `Space+gh` - View file history
- `Space+gf` - View current file history

### LSP
- `gd` - Go to definition
- `K` - Show documentation
- `Space+lr` - Rename symbol
- `Space+la` - Code action

### Visual Mode
- `<` / `>` - Indent left/right (stays in visual mode)
- `Alt+j/k` - Move selected text down/up

## License

MIT License - see [LICENSE](LICENSE) file