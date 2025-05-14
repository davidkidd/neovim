require("core.options")
require("core.keymaps")
require("core.autocmds")
require("plugins.plugins")
require("utils.compile")
require("utils.project")
-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
-- This is to ensure Mason doesn't try (and fail) to setup csharp-ls
local lspconfig = require("lspconfig")

lspconfig.csharp_ls.setup({
    cmd = { "csharp-ls" }, -- uses the binary on your PATH
    root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
    single_file_support = true,
})

-- Load the lackluster lualine theme
local lualine_theme = require("lualine.themes.lackluster")
local col = require("lackluster.color")

-- Override the insert mode colors
lualine_theme.insert = {
    a = { bg = col.lack, fg = col.black, gui = "bold" },
}
lualine_theme.command = {
    a = { bg = col.lack, fg = col.black, gui = "bold" },
}

-- Configure lualine with the modified theme
require("lualine").setup({
    options = {
        theme = lualine_theme, -- Use the modified theme
    },
})

-- This is for a kind of 'project telescope'
-- Function to find the project root based on common markers
-- local function find_project_root()
--     local markers = { ".git", ".csproj", ".sln" } -- Add more markers if needed
--     local path = vim.fn.expand("%:p:h") -- Get current file's directory
--     local root = vim.fn.finddir(".git/..", path .. ";") -- Look for .git first
--     if root ~= "" then
--         return root
--     end
--     -- Fallback to other markers if .git not found
--     for _, marker in ipairs(markers) do
--         root = vim.fn.findfile(marker, path .. ";")
--         if root ~= "" then
--             return vim.fn.fnamemodify(root, ":h") -- Get directory of the marker
--         end
--     end
--     -- Default to current working directory if no markers found
--     return vim.fn.getcwd()
-- end

-- Keymap for searching files in project root
-- vim.keymap.set("n", "<leader>sp", function()
--     require("telescope.builtin").find_files({
--         cwd = find_project_root(),
--         prompt_title = "Search Project Files",
--     })
-- end, { desc = "[S]earch [P]roject Files" })
--
-- Neogit
vim.keymap.set("n", "<leader>g", function()
    vim.cmd("Neogit cwd=%:p:h")
end, { desc = "Open git in repo of current file" })

-- Suppresses noisy errors inline
-- Customize LSP diagnostic display
vim.diagnostic.config({
    virtual_text = false, -- Disable inline virtual text
    signs = true, -- Keep signs in the gutter (e.g., red 'E' for errors)
    underline = true, -- Underline errors for visual feedback
    update_in_insert = false, -- Don't update diagnostics while typing
    severity_sort = true, -- Sort by severity (errors first)
    float = { -- Customize floating window appearance
        border = "single", -- Optional: rounded borders for the popup
        max_width = 80, -- Limit width to avoid screen overflow
        source = "always", -- Show diagnostic source (e.g., OmniSharp)
    },
})

vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float(nil, { scope = "line" })
end, { desc = "Show line diagnostics" })

-- Function to display diagnostics in the command-line area
local function show_diagnostic_in_echo()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

    if #diagnostics == 0 then
        vim.api.nvim_echo({ { "" } }, false, {})
        return
    end

    local diag = diagnostics[1]
    -- Get window width and command height
    local window_width = vim.api.nvim_get_option_value("columns", {})
    local cmdheight = vim.api.nvim_get_option_value("cmdheight", {})
    -- Less strict truncation
    local max_length = math.max(20, window_width - 50)
    if cmdheight == 1 then
        max_length = math.min(max_length, window_width - 30)
    end
    -- Replace newlines and truncate message
    local clean_message = diag.message:gsub("\n", " ")
    local truncated_message = string.sub(clean_message, 1, max_length)
    -- Format the message
    local message = string.format(
        "%s: %s (%s)",
        diag.severity == vim.diagnostic.severity.ERROR and "Error" or "Warning",
        truncated_message,
        diag.source or "LSP"
    )
    local severity_color = diag.severity == vim.diagnostic.severity.ERROR and "ErrorMsg" or "WarningMsg"

    -- Final length check
    local display_width = vim.fn.strdisplaywidth(message)
    local safe_length = math.min(80, window_width - 40)
    if display_width > safe_length then
        message = string.sub(message, 1, safe_length - 3) .. "..."
    end

    -- Simplified echo call
    vim.api.nvim_echo({ { message, severity_color } }, false, {})
end

-- Autocommand for CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
    callback = show_diagnostic_in_echo,
    desc = "Show diagnostics in echo area on CursorHold",
})

-- Keybinding: <leader>dd to open mini.files at current file's directory
vim.keymap.set("n", "<leader>dd", function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h") or vim.loop.cwd()
    require("mini.files").open(path, true)
end, { desc = "Open mini.files at current file directory" })

-- Add <leader>dp to allow path setting, prefilled with buf's current path
vim.keymap.set("n", "<leader>dp", function()
    local current_file_dir = vim.fn.expand("%:p:h") .. "/"
    vim.fn.feedkeys(":e " .. current_file_dir, "n")
end, { desc = "Open :e in current file directory for pathname input" })
