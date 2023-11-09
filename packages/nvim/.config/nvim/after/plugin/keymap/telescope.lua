local ok, builtin = pcall(require, 'telescope.builtin')
if not ok then
	return
end

local nnoremap = require('niko.keymap').nnoremap

nnoremap('<leader>ff', builtin.find_files)
nnoremap('<leader>fg', builtin.live_grep)
nnoremap('<leader>fG', vim.cmd.LiveGrepGitRoot)
nnoremap('<leader>fb', builtin.buffers)
nnoremap('<leader>fh', builtin.help_tags)
nnoremap('<leader>fB', builtin.current_buffer_fuzzy_find)

nnoremap('<leader>flr', builtin.lsp_references)
nnoremap('<leader>fls', builtin.lsp_document_symbols)
