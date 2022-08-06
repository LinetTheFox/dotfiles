-- #####################################
-- ########### Basic configs ###########
-- #####################################

local set = vim.opt
-- Show line numbers
set.nu = true

-- Show relative line numbers to help with using
-- commands with line counts such as "d10"
set.relativenumber = true

-- Set tab size to equal 4 symbols
set.tabstop = 4

-- Set the amount of spaces to use to shift text blocks
-- with '<' or '>'
set.shiftwidth = 4

-- Replace <Tab> with the tabstop spaces. Use Ctrl+V<Tab>
-- for actual tab "\t"
set.expandtab = true

-- Load vim-plug plugins
vim.cmd 'source ~/.config/nvim/vim-plug/plugins.vim'

-- #####################################
-- ########## Custom bindings ##########
-- #####################################

-- Use ",n" in normal mode to open or focus onto the
-- NERDTree
vim.keymap.set('n', ',n', ':NERDTreeFocus<CR>')

-- Use ",ft" to toggle the NERDTree display
vim.keymap.set('n', ',ft', ':NERDTreeToggle<CR>')

-- #####################################
-- ########### Extra actions ###########
-- #####################################

-- Support for Rust stuff like rust-analyzer
-- (requires nvim-lspconfig and rust-analyzer)
require('rust-tools').setup({})

-- Autocommand to run NERDTree when opening any file
vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    command = 'NERDTree',
})
