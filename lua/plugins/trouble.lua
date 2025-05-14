require("trouble").setup({
    warn_no_results = false,
    modes = {
        diagnostics = {
            auto_open = false,
            auto_close = false,
            focus = true,
            win = { position = "bottom", size = 10 },
        },
        quickfix = {
            auto_open = false,
            auto_close = false,
            focus = true,
            win = { position = "bottom", size = 10 },
        },
    },
})
