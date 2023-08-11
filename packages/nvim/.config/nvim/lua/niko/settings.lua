vim.opt.hidden = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

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
