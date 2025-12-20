local go_updated_marker = vim.fn.stdpath("data") .. "/go_nvim_updated"
local hooks = function(ev)
	-- Use available |event-data|
	local name, kind = ev.data.spec.name, ev.data.kind

	if name == 'go.nvim' and (kind == 'install' or kind == 'update') then
		-- Create a marker file to indicate that go tools should be updated.
		-- This is checked by a FileType autocommand for go files.
		vim.fn.writefile({ "" }, go_updated_marker)
	end
end
vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })

vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/vieitesss/gh-permalink.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/ray-x/go.nvim" },
	{ src = "https://github.com/ray-x/guihua.lua" },
	{ src = "https://github.com/benomahony/uv.nvim" },
})

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

require("gitsigns").setup({ signcolumn = false })
require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
	},
	sources = { default = { "lsp" } },
})
local actions = require("fzf-lua.actions")
require("fzf-lua").setup({})
require('go').setup({})
require('uv').setup({})
