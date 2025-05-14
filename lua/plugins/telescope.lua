-- lua/plugins/telescope.lua
local project = require("utils.project") -- Access find_project_root

require("telescope").setup({
    defaults = {
        layout_strategy = "flex", -- Use flex to switch between vertical and horizontal
        layout_config = {
            flex = {
                flip_columns = 160, -- Switch to vertical if window width < n columns
                flip_lines = 20, -- Switch to horizontal if window height < n lines
            },
            vertical = {
                prompt_position = "top",
                mirror = true, -- Preview at bottom
                height = 0.9,
                width = 0.8,
                preview_height = 0.4,
                preview_cutoff = 20, -- Preview shows only if n+ lines available
            },
            horizontal = {
                prompt_position = "top",
                height = 0.9,
                width = 0.8,
                preview_width = 0.5, -- Preview takes n% of width
                preview_cutoff = 160, -- Preview shows only if n+ columns available
            },
        },
        sorting_strategy = "ascending",
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
        },
    },
})

-- Enable Telescope extensions
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

-- Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>s/", function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
    })
end, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>sn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
vim.keymap.set("n", "<leader>sp", function()
    builtin.find_files({
        cwd = project.find_project_root(),
        prompt_title = "Search Project Files",
    })
end, { desc = "[S]earch [P]roject Files" })
