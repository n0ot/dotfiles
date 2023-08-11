local nnoremap = require('niko.keymap').nnoremap

local ok, _ = pcall(require, 'harpoon')
if not ok then
	return
end

nnoremap('<Leader>ha', function() require('harpoon.mark').add_file() end)
nnoremap('<Leader>hm', function() require('harpoon.ui').toggle_quick_menu() end)

nnoremap('<Leader>hj', function() require('harpoon.ui').nav_next() end)
nnoremap('<Leader>hk', function() require('harpoon.ui').nav_prev() end)

nnoremap('<Leader>h1', function() require('harpoon.ui').nav_file(1) end)
nnoremap('<Leader>h2', function() require('harpoon.ui').nav_file(2) end)
nnoremap('<Leader>h3', function() require('harpoon.ui').nav_file(3) end)
nnoremap('<Leader>h4', function() require('harpoon.ui').nav_file(4) end)
nnoremap('<Leader>h5', function() require('harpoon.ui').nav_file(5) end)
