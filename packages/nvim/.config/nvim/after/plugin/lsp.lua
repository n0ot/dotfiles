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
  clangd = {},
  efm = {
    filetypes = {
      'markdown',
      'sh',
    },
  },
  gopls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  pyright = {},
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
  tsserver = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local function on_attach(_, bufnr)
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

mason.setup()
-- Ensure the servers above are installed
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}
