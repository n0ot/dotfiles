local ok, _ = pcall(require, 'fzf')
if not ok then
	return
end


vim.env.FZF_DEFAULT_COMMAND = "fd -t f -E '*.{class,dll,exe,jar,o,pyc,so,war}' . $(scmroot " .. vim.fn.expand('%:p:h') .. ")"
vim.g.fzf_commits_log_options = '--oneline'
