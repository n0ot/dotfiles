-- Remap leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('niko.plugins')
require('niko.lsp')
require('niko.statusline')

-- Settings
vim.opt.hidden = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
vim.o.breakindent = true
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.wo.signcolumn = "yes"

-- Use US English spelling dictionary
-- Use set spell to turn it on
vim.opt.spelllang = 'en_us'
-- Enable spell check in some file types
vim.cmd('autocmd filetype svn,*commit*,markdown setlocal spell')

-- Accessibility
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.belloff = ''  -- Sometimes beeps for errors are helpful

vim.opt.ignorecase = true

vim.g.netrw_banner = 0


-- Key mappings
-- Navigate and manage buffers
vim.keymap.set('n', '<leader>j', vim.cmd.bnext)
vim.keymap.set('n', '<leader>k', vim.cmd.bprev)
vim.keymap.set('n', '<leader>c', vim.cmd.bdel)
vim.keymap.set('n', '<leader>C', function() vim.cmd.bdel{ bang = true } end)

vim.keymap.set('n', '<leader>e', '<Cmd>Explore<Cr>')

-- Delete to null register
vim.keymap.set('x', '<Leader>d', '"_d')
