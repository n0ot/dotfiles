-- Remap leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('niko.plugins')
require('niko.lsp')
require('niko.statusline')

-- Settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.completeopt = 'menuone,noselect'
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Use US English spelling dictionary
-- Use set spell to turn it on
vim.opt.spelllang = 'en_us'
-- Enable spell check in some file types
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('spell-ft', { clear = true }),
    pattern = { 'svn', '*commit*', 'markdown' },
    callback = function() vim.opt_local.spell = true end,
})

-- Accessibility
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.belloff = '' -- Audible cues help me (annoying for some, I know)

vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.netrw_banner = 0


-- Key mappings
-- Navigate and manage buffers
vim.keymap.set('n', ']b', vim.cmd.bnext, { desc = 'Next buffer' })
vim.keymap.set('n', '[b', vim.cmd.bprev, { desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>c', vim.cmd.bdel, { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>C', function() vim.cmd.bdel { bang = true } end, { desc = 'Force delete buffer' })

vim.keymap.set('n', '<leader>e', '<Cmd>Explore<Cr>', { desc = 'Explorer' })

-- Delete to null register
vim.keymap.set('x', '<Leader>d', '"_d', { desc = 'Delete without yanking' })
