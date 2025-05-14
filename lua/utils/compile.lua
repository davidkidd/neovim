-- lua/utils/compile.lua
local project = require("utils.project")

require("which-key").add({
    { "<leader>c", group = "[c]ompile" },
})

-- Configure :make for compilation
vim.opt.makeprg = ""
vim.opt.errorformat = "%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m,%f:%l: %m"

-- Compile from project root
vim.keymap.set("n", "<leader>cp", function()
    if vim.g.last_compile_command == nil or vim.g.last_compile_command == "" then
        vim.notify("No compile command set. Use <leader>ci to set one.", vim.log.levels.WARN)
        return
    end
    local root = project.find_project_root() or vim.fn.getcwd()
    local original_cwd = vim.fn.getcwd()
    vim.fn.chdir(root)
    vim.cmd("silent! wa")
    vim.opt.makeprg = vim.g.last_compile_command
    vim.cmd("make!")
    vim.fn.chdir(original_cwd)
end, { desc = "Save and run last compile command from project root" })

-- Define a custom command for interactive compilation with file completion
vim.api.nvim_create_user_command("Compile", function(opts)
    local input = opts.args
    if input and input ~= "" then
        -- Save the command for reuse
        vim.g.last_compile_command = input
        -- Store original settings
        local original_makeprg = vim.opt.makeprg
        local original_cwd = vim.fn.getcwd()
        -- Find project root or use current directory
        local root = project.find_project_root() or vim.fn.getcwd()
        -- Change to project root
        vim.fn.chdir(root)
        -- Check for modified buffers
        local has_modified = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, "modified") then
                has_modified = true
                break
            end
        end
        -- Prompt to save only if there are modified buffers
        local proceed = true
        if has_modified then
            local choice = vim.fn.confirm("Save all buffers before compiling?", "&Yes\n&No", 1, "Question")
            if choice == 1 then
                vim.cmd("wa")
            else
                proceed = false
                vim.notify("Compilation cancelled", vim.log.levels.INFO)
            end
        end
        -- Proceed with compilation if not cancelled
        if proceed then
            -- Set the compile command
            vim.opt.makeprg = input
            -- Run the command
            vim.cmd("make!")
        end
        -- Restore original settings
        vim.opt.makeprg = original_makeprg
        vim.fn.chdir(original_cwd)
    else
        vim.notify("No command provided", vim.log.levels.WARN)
    end
end, {
    nargs = 1, -- Expect one argument (the compile command)
    complete = "file", -- Enable file path completion
})

-- Keymap to open the command-line with the Compile command pre-filled
vim.keymap.set("n", "<leader>ci", function()
    local default = vim.g.last_compile_command or "make"
    -- Open the command-line with :Compile and the default command
    vim.fn.feedkeys(":Compile " .. vim.fn.escape(default, " ") .. " ", "n")
end, { desc = "Interactive compile from project root" })

-- Open Trouble for compilation errors
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "[^l]*",
    callback = function()
        if #vim.fn.getqflist() > 0 then
            vim.cmd("Trouble quickfix open")
        end
    end,
    desc = "Open Trouble for compilation errors",
})
