-- lua/plugins/conform.lua
require("conform").setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
        else
            return {
                timeout_ms = 500,
                lsp_format = "fallback",
            }
        end
    end,
    formatters_by_ft = {
        lua = { "stylua" },
    },
    formatters = {
        stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
        },
    },
})

-- Keymap for manual formatting
vim.keymap.set("", "<leader>f", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
