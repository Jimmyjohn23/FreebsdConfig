-- init.lua - Minimal FreeBSD Neovim nightly setup
-- Languages: C, C++, Python, Haskell, Bash, Assembly (via Treesitter)
-- Includes: LSP, Treesitter, Telescope, Gitsigns, Fugitive, Catppuccin, nvim-tree, lualine, which-key

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
  { src = 'https://github.com/p00f/nvim-ts-rainbow' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },

  -- lightweight docblock helper
  { src = 'https://github.com/danymat/neogen' },

  -- snippet engine (optional but useful)
  { src = 'https://github.com/L3MON4D3/LuaSnip' },

  -- which-key for leader popup
  { src = 'https://github.com/folke/which-key.nvim' },
}

-- 2. LSP servers
local lspconfig = require('lspconfig')
for _, lsp in ipairs({'clangd', 'pyright', 'hls', 'bashls'}) do
  lspconfig[lsp].setup{}
end

-- 3. Treesitter
require('nvim-treesitter.configs').setup{
  ensure_installed = { 'c', 'cpp', 'asm', 'bash', 'python', 'haskell' },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
  playground = { enable = true },
  rainbow = { enable = true, extended_mode = true, max_file_lines = 1000 },
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
  options = { theme = 'gruvbox', section_separators = '', component_separators = '' }
}

-- 9. Theme
vim.cmd.colorscheme('retrobox')

-- 10. Insert mode escape mapping
vim.keymap.set('i', 'jj', '<Esc>')

-- -------------------------
-- Doxygen / Neogen setup
-- -------------------------

-- Neogen: Doxygen-style comments for C/C++
do
  local ok_neogen, neogen = pcall(require, "neogen")
  if ok_neogen then
    neogen.setup {
      enabled = true,
      languages = {
        cpp = { template = { annotation_convention = "doxygen" } },
        c   = { template = { annotation_convention = "doxygen" } },
      },
    }
  else
    vim.notify("neogen not loaded (plugin may still be installing)", vim.log.levels.INFO)
  end
end

-- Async doxygen runner using libuv (non-blocking)
local function run_doxygen_async()
  if vim.fn.executable("doxygen") == 0 then
    vim.notify("doxygen not in PATH", vim.log.levels.ERROR)
    return
  end

  -- find Doxyfile up the tree or in cwd
  local doxy = vim.fn.findfile("Doxyfile", ".;")
  if doxy == "" then
    local try = vim.fn.getcwd() .. "/Doxyfile"
    if vim.fn.filereadable(try) == 0 then
      vim.notify("No Doxyfile found (search path and cwd)", vim.log.levels.ERROR)
      return
    end
    doxy = try
  end

  local uv = vim.loop
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local out_chunks = {}

  local tmp_log = vim.fn.tempname() .. ".doxygen.log"

  local handle
  handle = uv.spawn("doxygen", {
      args = { doxy },
      stdio = { nil, stdout, stderr },
    },
    function(code, _signal)
      if stdout then stdout:close() end
      if stderr then stderr:close() end
      if handle then handle:close() end

      local fd = io.open(tmp_log, "w")
      if fd then
        fd:write(table.concat(out_chunks, ""))
        fd:close()
      end

      vim.schedule(function()
        vim.cmd("cfile " .. vim.fn.fnameescape(tmp_log))
        if code == 0 then
          vim.notify("Doxygen finished successfully", vim.log.levels.INFO)
        else
          vim.notify("Doxygen exited with code " .. tostring(code), vim.log.levels.WARN)
        end
      end)
    end
  )

  stdout:read_start(function(err, data)
    assert(not err, err)
    if data then table.insert(out_chunks, data) end
  end)

  stderr:read_start(function(err, data)
    assert(not err, err)
    if data then table.insert(out_chunks, data) end
  end)

  vim.notify("Running doxygen (async) — will populate quickfix when done", vim.log.levels.INFO)
end

-- Keymaps: neogen generate & run doxygen
vim.keymap.set("n", "<leader>nd", function()
  local ok = pcall(require, "neogen")
  if not ok then
    vim.notify("neogen not available", vim.log.levels.ERROR)
    return
  end
  require("neogen").generate({})
end, { desc = "Neogen: generate docblock" })

vim.keymap.set("n", "<leader>dd", run_doxygen_async, { desc = "Run doxygen (async)" })

-- Auto-expand /** + <CR> into a neogen Doxygen docblock for C/C++/headers
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp", "h", "hpp"},
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set('i', '<CR>', function()
      local col = vim.fn.col('.')
      local line = vim.api.nvim_get_current_line()
      local before = line:sub(1, col - 1)
      if before:sub(-3) == '/**' then
        if pcall(require, "neogen") then
          return vim.api.nvim_replace_termcodes("<CR><C-o>:lua require('neogen').generate()<CR>", true, false, true)
        else
          return "\n"
        end
      end
      return "\n"
    end, { expr = true, buffer = bufnr })
  end,
})

-- -------------------------
-- which-key setup & registration
-- -------------------------
do
  local ok, wk = pcall(require, "which-key")
  if not ok then
    pcall(vim.cmd, "packadd which-key.nvim")
    ok, wk = pcall(require, "which-key")
  end

  if ok and wk then
    wk.setup {
      plugins = { marks = true, registers = true, spelling = { enabled = false } },
      window = { border = "single", position = "bottom" },
      triggers = "auto",
    }

    -- register leader mappings with descriptions
    wk.register({
      f = {
        name = "Find",
        f = { "<cmd>Telescope find_files<CR>", "Find files" },
        g = { "<cmd>Telescope live_grep<CR>", "Live grep" },
      },
      g = {
        name = "Git",
        s = { "<cmd>G<CR>", "Git status" },
        c = { "<cmd>G commit<CR>", "Commit" },
        p = { "<cmd>G push<CR>", "Push" },
        l = { "<cmd>G pull<CR>", "Pull" },
        m = { "<cmd>G merge<CR>", "Merge" },
      },
      e = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
      n = {
        name = "Neogen/Doxygen",
        d = { "<cmd>lua require('neogen').generate()<CR>", "Generate docblock" },
        r = { "<cmd>lua run_doxygen_async()<CR>", "Run Doxygen" },
      },
    }, { prefix = "<leader>" })
  else
    vim.notify("which-key not available — install folke/which-key.nvim to get leader popup", vim.log.levels.INFO)
  end
end

