-- 0. General settings
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.cursorline = true
vim.opt.updatetime = 300
vim.o.wildmenu = true
vim.o.wildmode = 'longest:full,full'
vim.g.mapleader = ' '

-- Clipboard
vim.opt.clipboard = 'unnamedplus'

-- 1. Plugins (native package manager)
vim.pack.add{
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/nvim-treesitter/playground' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = 'https://github.com/tpope/vim-fugitive' },
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/folke/which-key.nvim' },
    { src =  'https://github.com/lervag/vimtex' },
    { src = 'https://github.com/vim-pandoc/vim-pandoc' },
    { src = 'https://github.com/vim-pandoc/vim-pandoc-syntax' },
    { src = 'https://github.com/plasticboy/vim-markdown' },
    { src = 'https://github.com/JuliaEditorSupport/julia-vim' },
}

-- 2. LSP servers
vim.lsp.enable('clangd', 'pyright', 'hls', 'bashls', 'julials')

-- 3. Treesitter
require('nvim-treesitter.configs').setup{
    ensure_installed = { 'c', 'cpp', 'asm', 'bash', 'python', 'haskell', 'markdown', 'julia' },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
    playground = { enable = true },
}

-- 4. Telescope
require('telescope').setup{}
vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
vim.keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")

-- 5. Gitsigns
require('gitsigns').setup()

-- 6. Fugitive mappings
vim.keymap.set('n', '<leader>gs', ':G<CR>')
vim.keymap.set('n', '<leader>gc', ':G commit<CR>')
vim.keymap.set('n', '<leader>gp', ':G push<CR>')
vim.keymap.set('n', '<leader>gl', ':G pull<CR>')
vim.keymap.set('n', '<leader>gm', ':G merge<CR>')

-- 7. nvim-tree
require('nvim-tree').setup({
  git = { enable = true },
  view = { width = 30, side = "left" },
})
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

-- 8. lualine
require('lualine').setup{
  options = { theme = 'catppuccin', section_separators = '', component_separators = '' }
}



-- 9. Theme
vim.cmd.colorscheme('catppuccin')

-- 10. Insert mode escape mapping
vim.keymap.set('i', 'jj', '<Esc>')

-- Latex Setup 
vim.g.vimtex_view_method = 'zathura'      -- or okular, skim, etc.
vim.g.tex_flavor = 'latex'
vim.g.vimtex_quickfix_mode = 0


