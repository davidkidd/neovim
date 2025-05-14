-- lua/utils/compile.lua
local project = require("utils.project")

-- Configure :make for compilation
vim.opt.makeprg = ""
vim.opt.errorformat = "%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m,%f:%l: %m"

-- Compile from current CWD
vim.keymap.set("n", "<leader>cc", function()
    if vim.g.last_compile_command == nil or vim.g.last_compile_command == "" then
        vim.notify("No compile command set. Use <leader>ci to set one.", vim.log.levels.WARN)
        return
    end
    vim.cmd("silent! wa")
    vim.opt.makeprg = vim.g.last_compile_command
    vim.cmd("make!")
end, { desc = "Compile from current CWD" })

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
end, { desc = "Compile from project root" })

-- Interactive compile from project root
vim.keymap.set("n", "<leader>ci", function()
    vim.ui.input({
        prompt = "Compile command: ",
        default = vim.g.last_compile_command or "make",
    }, function(input)
        if input and input ~= "" then
            vim.g.last_compile_command = input
            local original_makeprg = vim.opt.makeprg
            local original_cwd = vim.fn.getcwd()
            local root = project.find_project_root() or vim.fn.getcwd()
            vim.fn.chdir(root)
            vim.cmd("silent! wa")
            vim.opt.makeprg = input
            vim.cmd("make!")
            vim.opt.makeprg = original_makeprg
            vim.fn.chdir(original_cwd)
        else
            vim.notify("No command provided", vim.log.levels.WARN)
        end
    end)
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
