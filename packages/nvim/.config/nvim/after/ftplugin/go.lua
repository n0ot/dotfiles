vim.bo.expandtab = false

local function goimports()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' }, diagnostics = {} }
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
    for cid, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
            elseif r.command then
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = 0,
    callback = goimports,
})

vim.keymap.set('n', '<localleader>e', function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local curr_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local indent = curr_line:match('^%s*')
    vim.api.nvim_buf_set_lines(0, line, line, false, {
        indent .. 'if err != nil {',
        indent .. '\t',
        indent .. '}',
    })
    vim.api.nvim_win_set_cursor(0, { line + 2, #(indent .. '\t') })
    vim.cmd('startinsert!')
end, { buffer = true, desc = 'if err != nil' })
