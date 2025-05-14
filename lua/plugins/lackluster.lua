require("lackluster").setup({
    tweak_color = {
        -- you can set a value to a custom hexcode like' #aaaa77' (hashtag required)
        -- or if the value is 'default' or nil it will use lackluster's default color
        -- lack = "#aaaa77",
        lack = "#ff822e",
        luster = "#FFFFFF",
        orange = "default",
        yellow = "default",
        green = "#FEA060",
        blue = "default",
        red = "default",
    },
    tweak_syntax = {
        string = "default",
        -- string = "#a1b2c3", -- custom hexcode
        -- string = color.green, -- lackluster color
        string_escape = "default",
        comment = "default",
        builtin = "default", -- builtin modules and functions
        type = "default",
        keyword = "#ff822e",
        keyword_return = "#ff822e",
        keyword_exception = "default",
    },
    tweak_highlight = {
        ["@keyword"] = {
            overwrite = false,
            bold = true,
            italic = false,
        },
        ["@function"] = {
            overwrite = false,
            bold = true,
            italic = false,
        },
    },
})
vim.cmd.colorscheme("lackluster")
-- Clear LSP reference highlights
vim.api.nvim_set_hl(0, "LspReferenceRead", {})
vim.api.nvim_set_hl(0, "LspReferenceWrite", {})
vim.api.nvim_set_hl(0, "LspReferenceText", {})
