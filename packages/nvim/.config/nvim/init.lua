require('niko.globals')


-- Remap leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- Plugins
-- Bootstrap lazy.nvim
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

require("lazy").setup("niko.plugins")


-- Settings
vim.opt.hidden = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
vim.o.breakindent = true
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

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

-- Select last pasted text
vim.keymap.set('n', 'gp', '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]')

-- Delete to null register
vim.keymap.set('x', '<Leader>d', '"_d')

vim.keymap.set('n', '<Leader><Leader>x', SaveAndSource)


-- Statusline
local function warn(msg)
    return '%#warningmsg#' .. msg .. '%*'
end

local statusLine = {
    '%{mode()} ',
    -- Filename (tail)
    '%t ',
    -- Warn if file format is not unix
    warn("%{&ff!='unix'?'['.&ff.'] ':''}"),
    -- Warn if encoding is not utf-8
    warn("%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.'] ':''}"),
    -- Readonly flag
    '%r',
    -- Modified flag
    '%m',
    -- File type
    '%y ',
    -- Show git branch/commit info
    '%{FugitiveStatusline()}',
}

vim.o.laststatus = 2
vim.o.statusline = table.concat(statusLine)
