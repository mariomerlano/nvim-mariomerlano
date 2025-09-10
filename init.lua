-- Basic Neovim Configuration

-- Plugin management with lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
  -- NvimTree file explorer (no fancy icons)
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    config = function()
      -- NvimTree configuration
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          side = "left",
        },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = false,
          full_name = false,
          highlight_opened_files = "none",
          highlight_modified = "none",
          root_folder_label = ":~:s?$?/..?",
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "+",
              edge = "|",
              item = "|",
              bottom = "-",
              none = " ",
            },
          },
          icons = {
            webdev_colors = false,
            git_placement = "before",
            modified_placement = "after",
            padding = " ",
            symlink_arrow = "->",
            show = {
              file = false,
              folder = false,
              folder_arrow = true,
              git = false,
              modified = true,
            },
            glyphs = {
              folder = {
                arrow_closed = "+",
                arrow_open = "-",
                default = "D",
                open = "O",
                empty = "E",
                empty_open = "EO",
                symlink = "S",
                symlink_open = "SO",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = false,
        },
      })
    end,
  },
  
  -- Telescope for fuzzy finding (dependency: ripgrep for live grep)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { 
            ".git/",
            ".next/",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
            "--glob=!.git/*",
          },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-v>"] = function()
                vim.api.nvim_feedkeys(vim.fn.getreg("+"), "i", true)
              end,
            },
          },
        },
      })
    end,
  },
  
  -- Diffview.nvim for Git diff visualization with split views and colored changes
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = false,
        signs = {
          fold_closed = "+",
          fold_open = "-",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
        file_panel = {
          win_config = {
            position = "left",
            width = 35,
          },
        },
      })
    end,
  },
  
  -- Fugitive - Git commands in nvim (simpler git integration)
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },
  
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",   -- Buffer source for completions
      "hrsh7th/cmp-path",     -- Path source for completions
      "L3MON4D3/LuaSnip",     -- Snippets engine
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- Tab to select an option
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          -- Shift+Tab to select previous option
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          -- Enter to confirm selection
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          -- Ctrl+Space to trigger completion
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        completion = {
          autocomplete = {
            require('cmp.types').cmp.TriggerEvent.TextChanged,
          },
          completeopt = 'menu,menuone,noselect',
        },
      })
    end,
  },
  
  -- Better syntax highlighting without Treesitter
  {
    "bfrg/vim-cpp-modern",
    ft = { "c", "cpp", "h", "hpp" },
  },
  
  -- Comment.nvim for smart code commenting
  {
    'numToStr/Comment.nvim',
    opts = {
      -- Add Ctrl+/ mappings
      toggler = {
        line = '<C-_>',  -- Ctrl+/ for line comment toggle
      },
      opleader = {
        line = '<C-_>',  -- Ctrl+/ in visual mode
      },
    },
    lazy = false,
  },
  
  -- Diff view for visualizing diffs with colors
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = false,
        signs = {
          fold_closed = "+",
          fold_open = "-",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
        file_panel = {
          win_config = {
            position = "left",
            width = 35,
          },
        },
      })
    end,
  },
})

-- General Settings
vim.opt.number = true                -- Show line numbers
vim.opt.relativenumber = true        -- Show relative line numbers
vim.opt.tabstop = 2                  -- Number of spaces tabs count for
vim.opt.shiftwidth = 2               -- Size of an indent
vim.opt.expandtab = true             -- Use spaces instead of tabs
vim.opt.smartindent = true           -- Insert indents automatically
vim.opt.wrap = false                 -- Don't wrap lines
vim.opt.ignorecase = true            -- Ignore case when searching
vim.opt.smartcase = true             -- Don't ignore case with capitals
vim.opt.termguicolors = true         -- Full color support (required for icons)
vim.opt.mouse = 'a'                  -- Enable mouse support for all modes
vim.opt.clipboard = 'unnamedplus'    -- Use system clipboard
vim.opt.mousemoveevent = true        -- Enable mouse move events

-- Mouse selection and copy settings
vim.keymap.set('v', '<C-c>', '"+y', { desc = 'Copy selection to clipboard' })  -- Explicit Ctrl+C in visual mode
vim.keymap.set('n', '<C-c>', 'vy', { desc = 'Copy current selection' })       -- Ctrl+C in normal mode
vim.opt.mousemodel = 'extend'        -- Allow selecting text with Shift+mouse
vim.opt.selectmode = 'mouse,key'     -- Enter select mode when using mouse or Shift+arrows

vim.opt.completeopt = 'menuone,noselect'  -- Better completion experience
vim.opt.updatetime = 250             -- Decrease update time
vim.opt.timeoutlen = 300             -- Decrease timeout length
vim.opt.scrolloff = 8                -- Lines of context
vim.opt.sidescrolloff = 8            -- Columns of context
vim.opt.splitbelow = true            -- Put new windows below current
vim.opt.splitright = true            -- Put new windows right of current
vim.opt.showmode = false             -- Don't show mode since we have a statusline
vim.opt.backup = false               -- No backup files
vim.opt.writebackup = false          -- No backup files
vim.opt.swapfile = false             -- No swap files
vim.opt.undofile = true              -- Persistent undo
vim.opt.hlsearch = true              -- Highlight search results
vim.opt.incsearch = true             -- Incremental search
vim.opt.signcolumn = 'yes'           -- Always show the signcolumn
vim.opt.cursorline = true            -- Highlight current line

-- Keymappings
vim.g.mapleader = ' '                -- Set leader key to space

-- Mappings for normal mode
vim.keymap.set('n', '<leader>w', function()
  local relative_path = vim.fn.fnamemodify(vim.fn.expand('%'), ':.')
  vim.fn.setreg('+', relative_path)
  print('Copied to clipboard: ' .. relative_path)
end, { desc = 'Copy relative file path to clipboard' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle File Explorer' })
vim.keymap.set('n', '<C-f>', '<cmd>Telescope live_grep<cr>', { desc = 'Search in all files (ripgrep)' })
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = 'Find files by name' })

-- Git diff view keymaps
-- Global variable to track diffview state
vim.g.diffview_is_open = false

vim.keymap.set('n', '<leader>g', function()
  -- Toggle DiffView open/close based on global state variable
  if vim.g.diffview_is_open then
    vim.cmd("DiffviewClose")
    vim.g.diffview_is_open = false
  else
    vim.cmd("DiffviewOpen")
    vim.g.diffview_is_open = true
  end
end, { desc = 'Toggle Git diff view (Space+g)' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'View file history' })
vim.keymap.set('n', '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', { desc = 'View current file history' })

-- Fix for DiffView requiring multiple :q commands
-- Create a simpler solution by adding a user command that overrides :q in diffview
vim.api.nvim_create_augroup("DiffviewCustom", { clear = true })

-- Listen for DiffviewClose command to update our state
vim.api.nvim_create_autocmd("User", {
  group = "DiffviewCustom",
  pattern = "DiffviewClose",
  callback = function()
    vim.g.diffview_is_open = false
  end,
})

-- Listen for DiffviewOpen command to update our state
vim.api.nvim_create_autocmd("User", {
  group = "DiffviewCustom",
  pattern = "DiffviewOpened",
  callback = function()
    vim.g.diffview_is_open = true
  end,
})

-- Create custom :q command for DiffView buffers
vim.api.nvim_create_user_command("DiffviewCloseWithQ", function()
  -- If we're in a diffview buffer, close the whole diffview
  local bufname = vim.fn.bufname()
  local filetype = vim.bo.filetype
  if bufname:match("diffview://") or filetype:match("^Diffview") then
    vim.cmd("DiffviewClose")
    -- Update our state variable
    vim.g.diffview_is_open = false
  else
    -- Otherwise, normal :q behavior
    vim.cmd("quit")
  end
end, {})

-- Override q mapping in diffview buffers
vim.api.nvim_create_autocmd({"FileType", "BufEnter"}, {
  group = "DiffviewCustom",
  callback = function()
    local bufname = vim.fn.bufname()
    local filetype = vim.bo.filetype
    
    if bufname:match("diffview://") or filetype:match("^Diffview") then
      -- Map 'q' to close diffview
      vim.keymap.set("n", "q", function()
        vim.cmd("DiffviewClose")
        vim.g.diffview_is_open = false
      end, {buffer = true})
      
      -- Override quit command in this buffer
      vim.cmd("cnoreabbrev <buffer> q DiffviewCloseWithQ")
      vim.cmd("cnoreabbrev <buffer> quit DiffviewCloseWithQ")
    end
  end,
})

-- Set bright diff colors like in the example
vim.api.nvim_create_autocmd("ColorScheme", {
  group = "DiffviewCustom",
  callback = function()
    -- Very bright red for deleted lines
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#ff0000", fg = "#ffffff", bold = true })
    -- Very bright green for added lines
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#00ff00", fg = "#000000", bold = true })
    -- Bright blue for changed text
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#0000ff", fg = "#ffffff", bold = true })
    -- Bright magenta for changed text within a line
    vim.api.nvim_set_hl(0, "DiffText", { bg = "#ff00ff", fg = "#ffffff", bold = true })
    
    -- Make sure these are applied to diffview's specific highlights too
    vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { link = "DiffDelete" })
    vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { link = "DiffAdd" })
    vim.api.nvim_set_hl(0, "DiffviewDiffChange", { link = "DiffChange" })
    vim.api.nvim_set_hl(0, "DiffviewDiffText", { link = "DiffText" })
  end,
})

-- Trigger the colorscheme event to apply the highlights immediately
vim.cmd("doautocmd ColorScheme")

-- Multiple mappings for Ctrl+Shift+P to increase compatibility across terminals
vim.keymap.set('n', '<C-S-p>', '<cmd>Telescope find_files<cr>', { desc = 'Find files by name (CS-P)' })
vim.keymap.set('n', '<F25>', '<cmd>Telescope find_files<cr>', { desc = 'Find files by name (F25 for some terminals)' }) 
vim.keymap.set('n', '<F13>', '<cmd>Telescope find_files<cr>', { desc = 'Find files by name (F13 for some terminals)' })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Resize windows with arrows
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase window width' })

-- Navigate buffers
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })

-- LSP navigation
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move text down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move text up' })

-- Theme
vim.cmd('colorscheme default')       -- Default colorscheme
vim.opt.background = 'dark'          -- Dark background
vim.api.nvim_set_hl(0, "Normal", { bg = "black" }) -- Set black background

-- Enhanced C/C++ syntax highlighting (works with vim-cpp-modern)
vim.api.nvim_create_autocmd({"BufEnter", "ColorScheme", "FileType"}, {
  pattern = {"*.c", "*.cpp", "*.h", "*.hpp", "c", "cpp"},
  callback = function()
    -- C Keywords (int, void, while, return, etc.)
    vim.api.nvim_set_hl(0, "cType", { fg = "#8be9fd", bold = true })
    vim.api.nvim_set_hl(0, "cStorageClass", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cStatement", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cConditional", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cRepeat", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cLabel", { fg = "#ff79c6", bold = true })
    
    -- Functions
    vim.api.nvim_set_hl(0, "Function", { fg = "#50fa7b", bold = true })
    vim.api.nvim_set_hl(0, "cUserFunction", { fg = "#50fa7b" })
    
    -- Preprocessor directives (#include, #define, etc.)
    vim.api.nvim_set_hl(0, "PreProc", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "cPreProc", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "cDefine", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "cInclude", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "Include", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "Define", { fg = "#f1fa8c", bold = true })
    
    -- Constants and numbers
    vim.api.nvim_set_hl(0, "Constant", { fg = "#bd93f9" })
    vim.api.nvim_set_hl(0, "cConstant", { fg = "#bd93f9" })
    vim.api.nvim_set_hl(0, "cNumber", { fg = "#bd93f9" })
    vim.api.nvim_set_hl(0, "Number", { fg = "#bd93f9" })
    vim.api.nvim_set_hl(0, "Float", { fg = "#bd93f9" })
    
    -- Strings
    vim.api.nvim_set_hl(0, "String", { fg = "#f1fa8c" })
    vim.api.nvim_set_hl(0, "cString", { fg = "#f1fa8c" })
    vim.api.nvim_set_hl(0, "Character", { fg = "#f1fa8c" })
    
    -- Comments
    vim.api.nvim_set_hl(0, "Comment", { fg = "#6272a4", italic = true })
    vim.api.nvim_set_hl(0, "cComment", { fg = "#6272a4", italic = true })
    vim.api.nvim_set_hl(0, "cCommentL", { fg = "#6272a4", italic = true })
    
    -- Operators
    vim.api.nvim_set_hl(0, "Operator", { fg = "#ff79c6" })
    vim.api.nvim_set_hl(0, "cOperator", { fg = "#ff79c6" })
    
    -- Identifiers
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#f8f8f2" })
    
    -- Special
    vim.api.nvim_set_hl(0, "Special", { fg = "#ff79c6" })
    vim.api.nvim_set_hl(0, "Delimiter", { fg = "#f8f8f2" })
    
    -- Keywords like return
    vim.api.nvim_set_hl(0, "Keyword", { fg = "#ff79c6", bold = true })
    
    -- Structures
    vim.api.nvim_set_hl(0, "Structure", { fg = "#8be9fd", bold = true })
    vim.api.nvim_set_hl(0, "cStructure", { fg = "#8be9fd", bold = true })
    
    -- vim-cpp-modern specific highlights
    vim.api.nvim_set_hl(0, "cppStatement", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cppAccess", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "cppType", { fg = "#8be9fd", bold = true })
    vim.api.nvim_set_hl(0, "cppModifier", { fg = "#ff79c6", bold = true })
  end,
})

-- LSP Configuration
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup common language servers
-- Lua LSP setup
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Python LSP setup (pyright)
lspconfig.pyright.setup{
  capabilities = capabilities,
}

-- JavaScript/TypeScript LSP setup (typescript-language-server)
lspconfig.ts_ls.setup{
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}

-- Basic C/C++ setup (clangd)
lspconfig.clangd.setup{
  capabilities = capabilities,
}

-- Global LSP keybindings
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover documentation' })
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'LSP rename' })
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'LSP code action' })

-- Remove duplicate setting as it's set above in General Settings

-- Custom :q command to close file and tree together
vim.api.nvim_create_user_command("SmartQuit", function()
  -- Check if NvimTree is open by looking for its buffer
  local nvim_tree_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("NvimTree") then
      nvim_tree_buf = buf
      break
    end
  end
  
  if nvim_tree_buf then
    -- Close NvimTree first
    local nvim_tree = require("nvim-tree.api")
    nvim_tree.tree.close()
  end
  
  -- Then quit the current buffer/window
  vim.cmd("quit")
end, {})

-- Custom :wq command to save, then close file and tree together
vim.api.nvim_create_user_command("SmartWriteQuit", function()
  -- Save the current file first
  vim.cmd("write")
  
  -- Check if NvimTree is open by looking for its buffer
  local nvim_tree_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("NvimTree") then
      nvim_tree_buf = buf
      break
    end
  end
  
  if nvim_tree_buf then
    -- Close NvimTree first
    local nvim_tree = require("nvim-tree.api")
    nvim_tree.tree.close()
  end
  
  -- Then quit the current buffer/window
  vim.cmd("quit")
end, {})

-- Custom :q! command to force quit file and tree together
vim.api.nvim_create_user_command("SmartForceQuit", function()
  -- Check if NvimTree is open by looking for its buffer
  local nvim_tree_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("NvimTree") then
      nvim_tree_buf = buf
      break
    end
  end
  
  if nvim_tree_buf then
    -- Close NvimTree first
    local nvim_tree = require("nvim-tree.api")
    nvim_tree.tree.close()
  end
  
  -- Then force quit the current buffer/window
  vim.cmd("quit!")
end, {})

-- Create autocmd to intercept quit commands
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = ":",
  callback = function()
    -- Map q to SmartQuit only in command mode
    vim.keymap.set('c', '<CR>', function()
      local cmd = vim.fn.getcmdline()
      if cmd == 'q' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>SmartQuit<CR>', true, false, true), 'n', true)
      elseif cmd == 'quit' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>SmartQuit<CR>', true, false, true), 'n', true)
      elseif cmd == 'wq' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>SmartWriteQuit<CR>', true, false, true), 'n', true)
      elseif cmd == 'q!' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-u>SmartForceQuit<CR>', true, false, true), 'n', true)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)
      end
    end, { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = ":",
  callback = function()
    -- Unmap when leaving command mode
    pcall(vim.keymap.del, 'c', '<CR>')
  end,
})

-- Debug key codes - Uncomment to view keycodes in real-time
-- vim.keymap.set('n', '<leader>k', function()
--   local function getcharstr()
--     local c = vim.fn.getchar()
--     if type(c) == "number" then
--       return vim.fn.nr2char(c)
--     end
--     return c
--   end
--   
--   local char = getcharstr()
--   local byte = string.byte(char)
--   vim.api.nvim_echo({{"Pressed: '" .. char .. "' (ASCII: " .. byte .. ")"}, {""}}, false, {})
-- end, { desc = 'Debug keycodes (press a key after)' })