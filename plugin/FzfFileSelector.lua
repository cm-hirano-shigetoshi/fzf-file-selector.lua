-- Check if the file has been loaded
if (vim.g.load_FzfFileSelector ~= nil) then
    return
else
    vim.g.load_FzfFileSelector = 1
end

-- Remap keys for file selector and gf function
vim.api.nvim_set_keymap('n', '<Plug>fzf-file-selector', '<Cmd>lua FzfFileSelector.run("")<CR>', { silent = true })
vim.api.nvim_set_keymap('n', 'l', '<Cmd>lua FzfFileSelector.gf(vim.fn.expand("<cfile>"))<CR>', { silent = true })
