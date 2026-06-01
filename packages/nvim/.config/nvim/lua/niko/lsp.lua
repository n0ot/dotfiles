vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local bufnr = event.buf
        vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,   { buffer = bufnr, desc = 'Go to definition' })
        vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,  { buffer = bufnr, desc = 'Go to declaration' })
        vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, { buffer = bufnr, desc = 'Show diagnostic' })
        vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format,        { buffer = bufnr, desc = 'Format buffer' })
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('lsp-format', { clear = true }),
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

require("mason").setup({})

local servers = {
    "bashls",
    "clangd",
    "golangci_lint_ls",
    "gopls",
    "lua_ls",
    "marksman",
    "protols",
    "ruff",
    "rust_analyzer",
    "tinymist",
    "ty",
    "ts_ls",
    "yamlls",
    "zls",
}

require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_enable = false,
})

vim.lsp.enable(servers)

