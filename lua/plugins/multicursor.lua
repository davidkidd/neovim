local mc = require("multicursor-nvim")
mc.setup()

local set = vim.keymap.set

-- Add or skip cursor above/below the main cursor.
set({ "n", "x" }, "<M-k>", function()
    mc.lineAddCursor(-1)
end, { desc = "Add cursor above" })
set({ "n", "x" }, "<M-j>", function()
    mc.lineAddCursor(1)
end, { desc = "Add cursor below" })
set({ "n", "x" }, "<leader>mk", function()
    mc.lineSkipCursor(-1)
end, { desc = "Skip cursor above" })
set({ "n", "x" }, "<leader>mj", function()
    mc.lineSkipCursor(1)
end, { desc = "Skip cursor below" })

-- Add or skip adding a new cursor by matching word/selection
set({ "n", "x" }, "<leader>mn", function()
    mc.matchAddCursor(1)
end, { desc = "Add cursor to next match" })
set({ "n", "x" }, "<leader>ms", function()
    mc.matchSkipCursor(1)
end, { desc = "Skip cursor to next match" })
set({ "n", "x" }, "<leader>mN", function()
    mc.matchAddCursor(-1)
end, { desc = "Add cursor to previous match" })
set({ "n", "x" }, "<leader>mS", function()
    mc.matchSkipCursor(-1)
end, { desc = "Skip cursor to previous match" })

-- Add and remove cursors with control + left click.
set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Add cursor with mouse" })
set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Drag to add cursor" })
set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Release mouse cursor" })

-- Disable and enable cursors.
set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle cursors" })

-- Mappings defined in a keymap layer only apply when there are
-- multiple cursors. This lets you have overlapping mappings.
mc.addKeymapLayer(function(layerSet)
    -- Select a different cursor as the main one.
    layerSet({ "n", "x" }, "<left>", mc.prevCursor)
    layerSet({ "n", "x" }, "<right>", mc.nextCursor)

    -- Delete the main cursor.
    layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

    -- Enable and clear cursors using escape.
    layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        else
            mc.clearCursors()
        end
    end)
end)
-- Advanced binds
set("n", "<leader>ma", mc.searchAllAddCursors, { desc = "Add cursors to all search matches" })
-- Customize how cursors look.
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { reverse = true })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

-- Register <leader>m menu label for which-key (non-deprecated method)
require("which-key").add({
    { "<leader>m", group = "[m]ulticursor" },
})
