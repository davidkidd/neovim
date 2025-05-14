require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "c",
        "c_sharp",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
    },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "c", "ruby" },
    },
    indent = { enable = true, disable = { "ruby" } },
    -- Add incremental selection configuration
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-n>", -- Start incremental selection
            node_incremental = "<C-n>", -- Expand to next node (up the scope)
            scope_incremental = "<C-s>", -- Expand to next scope (optional)
            node_decremental = "<C-p>", -- Shrink to previous node
        },
    },
    -- Add textobjects configuration
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to select textobject
            keymaps = {
                -- Define your keymaps for selecting functions
                ["af"] = { query = "@function.outer", desc = "Select around function" },
                ["if"] = { query = "@function.inner", desc = "Select inside function" },
            },
        },
    },
})
