vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
-- Map jk and kj to Esc in insert mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("i", "kj", "<Esc>", { noremap = true, silent = true })

-- Move line or selection up/down with Alt-p/Alt-n
vim.keymap.set("n", "<A-k>", ":m .-2<CR>", { noremap = true })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>", { noremap = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { noremap = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { noremap = true })

-- Select all
vim.keymap.set("n", "<A-v>", "ggVG", { noremap = true })

-- Bind control-BS to delete word in insert and command
vim.keymap.set({ "i", "c" }, "<C-BS>", "<C-w>", { noremap = true, desc = "Delete word backward with Ctrl-Backspace" })
