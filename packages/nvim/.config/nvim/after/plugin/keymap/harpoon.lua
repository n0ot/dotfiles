local ok, _ = pcall(require, 'harpoon')
if not ok then
	return
end

vim.keymap.set('n', '<Leader>ha', function() require('harpoon.mark').add_file() end)
vim.keymap.set('n', '<Leader>hm', function() require('harpoon.ui').toggle_quick_menu() end)

vim.keymap.set('n', '<Leader>hj', function() require('harpoon.ui').nav_next() end)
vim.keymap.set('n', '<Leader>hk', function() require('harpoon.ui').nav_prev() end)

vim.keymap.set('n', '<Leader>h1', function() require('harpoon.ui').nav_file(1) end)
vim.keymap.set('n', '<Leader>h2', function() require('harpoon.ui').nav_file(2) end)
vim.keymap.set('n', '<Leader>h3', function() require('harpoon.ui').nav_file(3) end)
vim.keymap.set('n', '<Leader>h4', function() require('harpoon.ui').nav_file(4) end)
vim.keymap.set('n', '<Leader>h5', function() require('harpoon.ui').nav_file(5) end)
