local ok, telescope = pcall(require, 'telescope')
if not ok then
    return
end

telescope.setup({
    defaults = {
        layout = 'vertical'
    }
})

require('telescope').load_extension('fzf')
require('telescope').load_extension('harpoon')
