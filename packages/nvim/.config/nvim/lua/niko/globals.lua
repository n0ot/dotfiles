P = function(v)
    print(vim.inspect(v))
    return v
end

SaveAndSource = function()
    if vim.bo.filetype == 'lua' then
    vim.cmd('write')
    vim.cmd('luafile %')
else
    vim.cmd('write')
    vim.cmd('source %')
    end
end
