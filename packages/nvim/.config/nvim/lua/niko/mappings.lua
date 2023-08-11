local fn = vim.fn
local nnoremap = require('niko.keymap').nnoremap
local xnoremap = require('niko.keymap').xnoremap

-- Remap leader key
vim.g.mapleader = ' '

-- Navigate and manage buffers
nnoremap('<leader>j', '<Cmd>bn<Cr>')
nnoremap('<leader>k', '<Cmd>bp<Cr>')
nnoremap('<leader>c', '<Cmd>bd<Cr>')
nnoremap('<leader>C', '<Cmd>bd!<Cr>')

nnoremap('<leader>e', '<Cmd>Explore<Cr>')

-- Select last pasted text
nnoremap('gp', '`[' .. fn.strpart(fn.getregtype(), 0, 1) .. '`]')

-- Delete to null register
xnoremap('<Leader>d', '"_d')

nnoremap('<Leader><Leader>x', SaveAndSource)
