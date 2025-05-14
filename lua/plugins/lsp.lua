-- lua/plugins/lsp.lua
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = function(event)
        -- Helper function to define LSP mappings
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- LSP keymaps
        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
        map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
        map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
        map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

        -- Document highlighting support check
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                end,
            })
        end
    end,
})

-- Diagnostic configuration
vim.diagnostic.config({
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    } or {},
    virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
})

-- Get LSP capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- LSP server configurations
local servers = {
    clangd = {
        filetypes = { "c", "cpp" },
    },
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Replace",
                },
            },
        },
    },
}

-- Setup Mason and ensure tools are installed

require("mason").setup({})
require("mason-tool-installer").setup({
    ensure_installed = vim.list_extend(vim.tbl_keys(servers or {}), { "stylua" }),
})

-- Setup LSP servers via mason-lspconfig
require("mason-lspconfig").setup({
    ensure_installed = {}, -- Explicitly empty, as mason-tool-installer handles installs
    automatic_installation = false,
    handlers = {
        function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
        end,
    },
})

-- Setup fidget and lazydev (loaded by lazy.nvim)
require("fidget").setup({})
require("lazydev").setup({
    library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
})

local lspconfig = require("lspconfig")
lspconfig.csharp_ls.setup({
    cmd = { "csharp-ls" }, -- uses the binary on your PATH
    root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
    single_file_support = true,
})

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
