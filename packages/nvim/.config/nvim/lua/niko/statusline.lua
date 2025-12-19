-- Statusline
local function warn(msg)
    return '%#warningmsg#' .. msg .. '%*'
end

local statusLine = {
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
    '%{FugitiveStatusline()}',
}

vim.o.laststatus = 2
vim.o.statusline = table.concat(statusLine)
