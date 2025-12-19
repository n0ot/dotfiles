---@type vim.lsp.Config
return {
    before_init = function(_, config)
        config.init_options = {
            include_paths = {
                "proto",
                ".protodep",
            },
        }
    end,
}
