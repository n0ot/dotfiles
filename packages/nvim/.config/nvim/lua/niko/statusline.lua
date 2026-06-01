-- Statusline
local function warn(msg)
    return '%#warningmsg#' .. msg .. '%*'
end

local fugitive_section = vim.fn.exists('*FugitiveStatusline') == 1
    and '%{FugitiveStatusline()}'
    or ''

local status_line = {
    '%{mode()} ',
    -- Filename (tail)
    '%t ',
    -- Warn if file format is not unix
    warn("%{&ff!='unix'?'['.&ff.'] ':''}"),
    -- Warn if encoding is not utf-8
    warn("%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.'] ':''}"),
    -- Readonly flag
    '%r',
    -- Modified flag
    '%m',
    -- File type
    '%y ',
    -- Show git branch/commit info
    fugitive_section,
}

vim.o.laststatus = 3
vim.o.statusline = table.concat(status_line)
