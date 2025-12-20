vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local bufnr = event.buf
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr })
        vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr })
        vim.keymap.set('n', '<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
            { buffer = bufnr })
        vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, { buffer = bufnr })
        vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { buffer = bufnr })
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
})

vim.diagnostic.config({ signs = true })
