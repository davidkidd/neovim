vim.keymap.set("n", "<leader>g", function()
    vim.cmd("Neogit cwd=%:p:h")
end, { desc = "Open git in repo of current file" })
