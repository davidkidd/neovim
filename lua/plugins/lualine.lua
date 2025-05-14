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
