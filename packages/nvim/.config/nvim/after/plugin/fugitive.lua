local ok, _ = pcall(require, 'fugitive')
if not ok then
	return
end

-- Remove fugitive buffers when hidden
vim.cmd('autocmd BufReadPost fugitive://* set bufhidden=delete')
