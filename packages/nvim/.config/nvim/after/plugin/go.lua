local ok, go = pcall(require, 'go')
if not ok then
	return
end

local go_install_tools_grp = vim.api.nvim_create_augroup("GoInstallTools", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go,gomod",
	group = go_install_tools_grp,
	callback = function()
		local go_updated_marker = vim.fn.stdpath("data") .. "/go_nvim_updated"
		if vim.fn.filereadable(go_updated_marker) == 1 then
			require("go.install").update_all_sync()
			vim.fn.delete(go_updated_marker)
		end
	end,
})

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		require('go.format').goimports()
	end,
	group = format_sync_grp,
})
