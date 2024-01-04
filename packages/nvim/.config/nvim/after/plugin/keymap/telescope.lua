local ok, builtin = pcall(require, 'telescope.builtin')
if not ok then
	return
end

vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>fG', vim.cmd.LiveGrepGitRoot)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>fB', builtin.current_buffer_fuzzy_find)

vim.keymap.set('n', '<leader>flr', builtin.lsp_references)
vim.keymap.set('n', '<leader>fls', builtin.lsp_document_symbols)
