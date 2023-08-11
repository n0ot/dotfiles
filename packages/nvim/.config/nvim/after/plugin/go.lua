local ok, go = pcall(require, 'go')
if not ok then
	return
end

go.setup()

vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').goimport() ]], false)
