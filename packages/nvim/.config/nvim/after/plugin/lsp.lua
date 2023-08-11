local nnoremap = require("niko.keymap").nnoremap

local ok, mason, mason_lspconfig
ok, mason = pcall(require, 'mason')
if not ok then
    return
end
ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok then
    return
end

-- per-server configuration
local servers = {
    sumneko_lua = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    },
    efm = {
        filetypes = {
            'markdown',
            'sh',
        },
    },
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = {
                diagnostics = {
                    enable = true,
                    experimental = {
                        enable = true,
                    },
                },
            },
        },
    },
}

local non_mason_servers = {
    ccls = {
        -- capabilities = capabilities,
        cmd = { "ccls" },
        filetypes = { "cpp", "c", "objcpp", "objc" },
        root_dir = require("lspconfig/util").root_pattern("compile_commands.json", ".ccls", ".git"),
        single_file_support = true,
    },
}

local function config(_config)
    return vim.tbl_deep_extend("force", {
        on_attach = function(_, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            nnoremap('gD', vim.lsp.buf.declaration, { buffer = bufnr })
            nnoremap('gd', vim.lsp.buf.definition, { buffer = bufnr })
            nnoremap('K', vim.lsp.buf.hover, { buffer = bufnr })
            nnoremap('gi', vim.lsp.buf.implementation, { buffer = bufnr })
            nnoremap('<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
            nnoremap('<leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr })
            nnoremap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr })
            nnoremap('<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
                { buffer = bufnr })
            nnoremap('<leader>lD', vim.lsp.buf.type_definition, { buffer = bufnr })
            nnoremap('<leader>lrn', vim.lsp.buf.rename, { buffer = bufnr })
            nnoremap('<leader>lca', vim.lsp.buf.code_action, { buffer = bufnr })
            nnoremap('gr', vim.lsp.buf.references, { buffer = bufnr })
            nnoremap('<leader>le', vim.diagnostic.open_float, { buffer = bufnr })
            nnoremap('[d', vim.diagnostic.goto_prev, { buffer = bufnr })
            nnoremap(']d', vim.diagnostic.goto_next, { buffer = bufnr })
            nnoremap('<leader>lq', vim.diagnostic.setloclist, { buffer = bufnr })
            nnoremap('<leader>lf', vim.lsp.buf.format, { buffer = bufnr })
        end
    }, _config or {})
end

mason.setup()
mason_lspconfig.setup_handlers({
    function(server_name)
        local cfg = config(servers[server_name] or {})
        require("lspconfig")[server_name].setup(cfg)
    end
})

-- Setup non Mason servers
for name, cfg in pairs(non_mason_servers) do
    local _cfg = config(cfg) or {}
    require("lspconfig")[name].setup(_cfg)
end
