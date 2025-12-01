local ok, lspconfig, mason, mason_lspconfig
ok, lspconfig = pcall(require, 'lspconfig')
if not ok then
  return
end
ok, mason = pcall(require, 'mason')
if not ok then
  return
end
ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not ok then
  return
end

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local function on_attach(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
  vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr })
  vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr })
  vim.keymap.set('n', '<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    { buffer = bufnr })
  vim.keymap.set('n', '<leader>lD', vim.lsp.buf.type_definition, { buffer = bufnr })
  vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, { buffer = bufnr })
  vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, { buffer = bufnr })
  vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { buffer = bufnr })
end

-- per-server configuration
local servers = {
  bashls = {},
  clangd = {
    filetypes = { "c", "c++", "cpp", "h", "objc", "objcpp" }, -- Exclude .proto
  },
  golangci_lint_ls = {},
  gopls = {
    settings = {
      gopls = {
        allExperiments = true,
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  marksman = {},
  protols = {
    before_init = function(_, config)
      config.init_options = {
        include_paths = {
          "proto",
          ".protodep",
        },
      }
    end,
  },
  ruff = {},
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
  tinymist = {},
  ts_ls = {},
  zls = {},
}

local function setup_server(server, config)
  config = vim.tbl_deep_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
  }, config)

  lspconfig[server].setup(config)
end

mason.setup()
mason_lspconfig.setup {}

for server, config in pairs(servers) do
  setup_server(server, config)
end
