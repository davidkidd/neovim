-- lua/utils/project.lua
local M = {}

function M.find_project_root()
    local markers = { ".git", ".csproj", ".sln" }
    local path = vim.fn.expand("%:p:h")
    local root = vim.fn.finddir(".git/..", path .. ";")
    if root ~= "" then
        return root
    end
    for _, marker in ipairs(markers) do
        root = vim.fn.findfile(marker, path .. ";")
        if root ~= "" then
            return vim.fn.fnamemodify(root, ":h")
        end
    end
    return vim.fn.getcwd()
end

return M
