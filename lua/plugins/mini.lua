-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require("mini.ai").setup({
    n_lines = 500,
})

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require("mini.surround").setup()

require("mini.files").setup({})

-- Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require("mini.statusline")
-- set use_icons to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
    return "%2l:%-2v"
end

require("which-key").add({
    { "<leader>d", group = "[d]irectory" },
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
