local PLUGIN_DIR = vim.fn.expand('<sfile>:p:h:h')
local PYTHON = vim.fn.getenv("FZF_FILE_SELECTOR_PYTHON") or "python"
local CURL = vim.fn.getenv("FZF_FILE_SELECTOR_CURL") or "curl"

local server_pid = -1

local FzfFileSelector = {}

function FzfFileSelector.start_server()
    if server_pid >= 0 then
        vim.fn.jobstop(server_pid)
    end
    local server_port = vim.fn.system({PYTHON, PLUGIN_DIR .. "/python/find_available_port.py"})
    server_pid = vim.fn.jobstart({PYTHON, PLUGIN_DIR .. "/python/internal_server.py", ".", server_port})
    return server_port
end

function FzfFileSelector.gf(query)
    if vim.api.nvim_eval('has("nvim")') == 1 then
        -- Assuming is_gf_accessible is converted to a Lua function already
        if FzfFileSelector.is_gf_accessible(query) then
            vim.api.nvim_feedkeys("gf", "n", {})
        else
            vim.g.fzf_layout = { window = 'enew' }
            local server_port = FzfFileSelector.start_server()

            local command_str = vim.fn.system({PYTHON, PLUGIN_DIR .. "/python/create_fzf_command.py", ".", query, server_port})
            local command_json = vim.fn.json_decode(command_str)

            local fd_command = command_json["fd_command"]
            local fzf_dict = command_json["fzf_dict"]
            local fzf_port = command_json["fzf_port"]

            vim.fn.system({CURL, "localhost:" .. server_port .. "?set_fzf_port=" .. fzf_port})
            -- Assuming get_selected_items is converted to a Lua function already
            FzfFileSelector.get_selected_items(fd_command, fzf_dict, fzf_port)
        end
    end
end

_G.FzfFileSelector = FzfFileSelector
