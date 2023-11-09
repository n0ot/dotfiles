P = function(v)
  print(vim.inspect(v))
  return v
end

SaveAndSource = function()
  vim.cmd('write')
  if vim.bo.filetype == 'lua' then
    vim.cmd('luafile %')
  else
    vim.cmd('source %')
  end
end
