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

      -- Custom source for markdown image/link paths
      local markdown_path_source = {}
      markdown_path_source.new = function()
        return setmetatable({}, { __index = markdown_path_source })
      end

      function markdown_path_source:get_trigger_characters()
        return { '/' }
      end

      function markdown_path_source:complete(params, callback)
        local line = params.context.cursor_before_line
        -- Match pattern like ![...](path/ or [...](...path/
        local path_match = line:match('%]%(([^%)]+)$')
        if not path_match then
          callback({ items = {}, isIncomplete = false })
          return
        end

        -- Get the directory part of the path
        local base_dir = vim.fn.expand('%:p:h')
        local target_dir = base_dir .. '/' .. path_match

        -- Check if directory exists
        if vim.fn.isdirectory(target_dir) ~= 1 then
          callback({ items = {}, isIncomplete = false })
          return
        end

        -- Get files from directory
        local files = vim.fn.readdir(target_dir)
        local items = {}
        for _, file in ipairs(files) do
          local full_path = target_dir .. '/' .. file
          local is_dir = vim.fn.isdirectory(full_path) == 1
          table.insert(items, {
            label = file,
            kind = is_dir and 19 or 17, -- Folder or File icon
            insertText = file,
            sortText = (is_dir and '0' or '1') .. file, -- Folders first
          })
        end

        callback({ items = items, isIncomplete = false })
      end

      function markdown_path_source:get_keyword_pattern()
        return [[\k\+]]
      end

      cmp.register_source('markdown_path', markdown_path_source.new())

      -- Markdown-specific completion: use custom path source
      cmp.setup.filetype('markdown', {
        sources = cmp.config.sources({
          { name = 'markdown_path' },
          { name = 'buffer' },
        }),
      })

      -- Auto-trigger completion after typing "/" in markdown image/link context
      vim.api.nvim_create_autocmd("InsertCharPre", {
        pattern = "*.md",
        callback = function()
          if vim.v.char == '/' then
            vim.defer_fn(function()
              local line = vim.api.nvim_get_current_line()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              local before_cursor = line:sub(1, col + 1)
              if before_cursor:match('%]%([^%)]*/$') then
                require('cmp').complete()
              end
            end, 10)
          end
        end,
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

-- Accent-insensitive search
local accent_map = {
  ['a'] = '[aáàäâã]', ['A'] = '[AÁÀÄÂÃ]',
  ['e'] = '[eéèëê]',  ['E'] = '[EÉÈËÊ]',
  ['i'] = '[iíìïî]',  ['I'] = '[IÍÌÏÎ]',
  ['o'] = '[oóòöôõ]', ['O'] = '[OÓÒÖÔÕ]',
  ['u'] = '[uúùüû]',  ['U'] = '[UÚÙÜÛ]',
  ['n'] = '[nñ]',     ['N'] = '[NÑ]',
}

local function transform_pattern(input)
  return input:gsub('.', function(c)
    return accent_map[c] or c
  end)
end

-- Override Enter in search mode to transform the pattern
vim.keymap.set('c', '<CR>', function()
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype == '/' or cmdtype == '?' then
    local input = vim.fn.getcmdline()
    if input ~= '' then
      local pattern = transform_pattern(input)
      -- Replace cmdline with transformed pattern and execute
      return '<C-u>' .. pattern .. '<CR>'
    end
  end
  return '<CR>'
end, { expr = true })
vim.opt.termguicolors = true         -- Full color support (required for icons)
vim.opt.mouse = 'a'                  -- Enable mouse support for all modes
vim.opt.clipboard = 'unnamedplus'    -- Use system clipboard
vim.opt.mousemoveevent = true        -- Enable mouse move events

-- Mouse selection and copy settings
vim.keymap.set('v', '<C-c>', '"+y', { desc = 'Copy selection to clipboard' })  -- Explicit Ctrl+C in visual mode
vim.keymap.set('n', '<C-c>', 'vy', { desc = 'Copy current selection' })       -- Ctrl+C in normal mode

-- Ctrl+Click to open URLs in browser or images in viewer
vim.keymap.set('n', '<C-LeftMouse>', function()
  local word = vim.fn.expand('<cWORD>')
  -- Extract URL from the word (handles markdown links, quotes, parentheses)
  local url = word:match('https?://[%w%-%.%_%~%:%/%?%#%[%]%@%!%$%&%\'%(%)%*%+%,%;%%=]+')
  if url then
    -- Clean trailing punctuation that's not part of URL
    url = url:gsub('[%)%]%>%,%.%;%:%!%?]+$', '')
    vim.fn.system({ 'xdg-open', url })
    return
  end

  -- Check for image file paths
  local path = word:match('[%w%-%.%_%/]+%.png') or
               word:match('[%w%-%.%_%/]+%.jpg') or
               word:match('[%w%-%.%_%/]+%.jpeg') or
               word:match('[%w%-%.%_%/]+%.gif') or
               word:match('[%w%-%.%_%/]+%.webp') or
               word:match('[%w%-%.%_%/]+%.bmp')
  if path then
    -- Clean markdown/parentheses artifacts
    path = path:gsub('^[%(%[%]%)]', ''):gsub('[%(%[%]%)]+$', '')
    -- Make path absolute if relative
    if not path:match('^/') then
      path = vim.fn.getcwd() .. '/' .. path
    end
    if vim.fn.filereadable(path) == 1 then
      vim.fn.system({ 'xdg-open', path })
    else
      vim.notify('Image not found: ' .. path, vim.log.levels.WARN)
    end
  end
end, { desc = 'Open URL or image under cursor' })
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
-- Live grep with accent-insensitive search
vim.keymap.set('n', '<C-f>', function()
  local accent_map = {
    ['a'] = '[aáàäâã]', ['A'] = '[AÁÀÄÂÃ]',
    ['e'] = '[eéèëê]',  ['E'] = '[EÉÈËÊ]',
    ['i'] = '[iíìïî]',  ['I'] = '[IÍÌÏÎ]',
    ['o'] = '[oóòöôõ]', ['O'] = '[OÓÒÖÔÕ]',
    ['u'] = '[uúùüû]',  ['U'] = '[UÚÙÜÛ]',
    ['n'] = '[nñ]',     ['N'] = '[NÑ]',
  }
  require('telescope.builtin').live_grep({
    on_input_filter_cb = function(prompt)
      local pattern = prompt:gsub('.', function(c)
        return accent_map[c] or c
      end)
      return { prompt = pattern }
    end,
  })
end, { desc = 'Search in all files (accent-insensitive)' })
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

-- Clear search highlighting with Escape
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlighting' })

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

-- Set search highlight to softer colors
vim.api.nvim_set_hl(0, "Search", { bg = "#2a3f5f", fg = "#8be9fd" })  -- Soft dark blue background with light blue text
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#8be9fd", fg = "#000000", bold = true })  -- Strong light blue for current match
vim.api.nvim_set_hl(0, "CurSearch", { bg = "#8be9fd", fg = "#000000", bold = true })  -- Current search item when navigating with n/N

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

-- Enhanced Markdown syntax highlighting
vim.api.nvim_create_autocmd({"BufEnter", "ColorScheme", "FileType"}, {
  pattern = {"*.md", "*.markdown", "markdown"},
  callback = function()
    -- Headers (h1-h6)
    vim.api.nvim_set_hl(0, "markdownH1", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "markdownH2", { fg = "#bd93f9", bold = true })
    vim.api.nvim_set_hl(0, "markdownH3", { fg = "#8be9fd", bold = true })
    vim.api.nvim_set_hl(0, "markdownH4", { fg = "#50fa7b", bold = true })
    vim.api.nvim_set_hl(0, "markdownH5", { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, "markdownH6", { fg = "#ffb86c", bold = true })
    vim.api.nvim_set_hl(0, "markdownHeadingDelimiter", { fg = "#6272a4" })

    -- Bold and italic
    vim.api.nvim_set_hl(0, "markdownBold", { fg = "#ffb86c", bold = true })
    vim.api.nvim_set_hl(0, "markdownItalic", { fg = "#f1fa8c", italic = true })
    vim.api.nvim_set_hl(0, "markdownBoldItalic", { fg = "#ffb86c", bold = true, italic = true })

    -- Code blocks and inline code
    vim.api.nvim_set_hl(0, "markdownCode", { fg = "#50fa7b", bg = "#282a36" })
    vim.api.nvim_set_hl(0, "markdownCodeBlock", { fg = "#50fa7b" })
    vim.api.nvim_set_hl(0, "markdownCodeDelimiter", { fg = "#6272a4" })

    -- Links and URLs
    vim.api.nvim_set_hl(0, "markdownLinkText", { fg = "#8be9fd", underline = true })
    vim.api.nvim_set_hl(0, "markdownUrl", { fg = "#6272a4", underline = true })
    vim.api.nvim_set_hl(0, "markdownIdDeclaration", { fg = "#8be9fd" })
    vim.api.nvim_set_hl(0, "markdownLinkDelimiter", { fg = "#6272a4" })

    -- Lists
    vim.api.nvim_set_hl(0, "markdownListMarker", { fg = "#ff79c6", bold = true })
    vim.api.nvim_set_hl(0, "markdownOrderedListMarker", { fg = "#ff79c6", bold = true })

    -- Blockquotes
    vim.api.nvim_set_hl(0, "markdownBlockquote", { fg = "#6272a4", italic = true })

    -- Horizontal rules
    vim.api.nvim_set_hl(0, "markdownRule", { fg = "#6272a4" })

    -- Special characters
    vim.api.nvim_set_hl(0, "markdownEscape", { fg = "#ffb86c" })
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