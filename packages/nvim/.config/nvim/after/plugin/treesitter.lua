local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not ok then
    return
end

treesitter.setup({
    indent = {
        enable = true,
    },
    highlight = {
        enable = true,
    },
})
