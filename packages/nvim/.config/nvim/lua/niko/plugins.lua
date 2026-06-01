vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
	{ src = "https://github.com/vieitesss/gh-permalink.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/benomahony/uv.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
})

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

require("lazydev").setup({})
local ts_parsers = {
	"bash", "c", "cpp", "go", "gomod", "gosum",
	"lua", "markdown", "proto", "python", "rust",
	"typescript", "typst", "yaml", "zig", "vim", "vimdoc",
}
require("nvim-treesitter").setup({
	highlight = { enable = true },
	indent    = { enable = true },
})
vim.api.nvim_create_autocmd('VimEnter', {
	once = true,
	callback = function()
		require('nvim-treesitter.install').install(ts_parsers)
	end,
})

require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
	move   = { set_jumps = true },
})

local ts_sel  = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({'x','o'}, 'af', function() ts_sel.select_textobject('@function.outer', 'textobjects') end, { desc = 'outer function' })
vim.keymap.set({'x','o'}, 'if', function() ts_sel.select_textobject('@function.inner', 'textobjects') end, { desc = 'inner function' })
vim.keymap.set({'x','o'}, 'aa', function() ts_sel.select_textobject('@parameter.outer', 'textobjects') end, { desc = 'outer parameter' })
vim.keymap.set({'x','o'}, 'ia', function() ts_sel.select_textobject('@parameter.inner', 'textobjects') end, { desc = 'inner parameter' })

vim.keymap.set('n', ']f', function() ts_move.goto_next_start('@function.outer', 'textobjects') end,     { desc = 'Next function' })
vim.keymap.set('n', '[f', function() ts_move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Prev function' })
vim.keymap.set('n', ']a', function() ts_move.goto_next_start('@parameter.inner', 'textobjects') end,     { desc = 'Next parameter' })
vim.keymap.set('n', '[a', function() ts_move.goto_previous_start('@parameter.inner', 'textobjects') end, { desc = 'Prev parameter' })

require("gitsigns").setup({
	signcolumn = false,
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local opts = { buffer = bufnr }
		vim.keymap.set('n', ']h', gs.next_hunk,       vim.tbl_extend('force', opts, { desc = 'Next hunk' }))
		vim.keymap.set('n', '[h', gs.prev_hunk,       vim.tbl_extend('force', opts, { desc = 'Prev hunk' }))
		vim.keymap.set('n', '<leader>hs', gs.stage_hunk,      vim.tbl_extend('force', opts, { desc = 'Stage hunk' }))
		vim.keymap.set('n', '<leader>hr', gs.reset_hunk,      vim.tbl_extend('force', opts, { desc = 'Reset hunk' }))
		vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, vim.tbl_extend('force', opts, { desc = 'Unstage hunk' }))
		vim.keymap.set('n', '<leader>hb', gs.blame_line,      vim.tbl_extend('force', opts, { desc = 'Blame line' }))
	end,
})
require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
	},
	sources = { default = { "lsp", "path", "buffer" } },
	keymap = {
		preset = 'none',
		['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
		['<C-e>'] = { 'hide' },
		['<C-y>'] = { 'select_and_accept' },
		['<C-n>'] = { 'select_next', 'fallback' },
		['<C-p>'] = { 'select_prev', 'fallback' },
		['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
		['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
		['<Tab>'] = { 'snippet_forward', 'fallback' },
		['<S-Tab>'] = { 'snippet_backward', 'fallback' },
	},
})
vim.keymap.set({'n','x'}, '<leader>gy', require("gh-permalink").yank, { desc = 'Copy GitHub permalink' })

require("fzf-lua").setup({})
local fzf = require("fzf-lua")
vim.keymap.set('n', '<leader>ff', fzf.files,     { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers,   { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = 'Help tags' })
require("which-key").setup({})
require('uv').setup({})

-- Remove fugitive buffers when hidden
vim.api.nvim_create_autocmd('BufReadPost', {
	group = vim.api.nvim_create_augroup('fugitive-cleanup', { clear = true }),
	pattern = 'fugitive://*',
	callback = function() vim.opt_local.bufhidden = 'delete' end,
})
