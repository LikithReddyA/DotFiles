local M = {}

function M.setup()
  require("nvim-tree").setup {
    disable_netrw = true,
    hijack_netrw = true,
    view = {
      width = 30,
      number = true,
      relativenumber = true,
    },
    filters = {
      custom = { ".git" },
    },
    update_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    }, 
    actions = {
        open_file = {
            quit_on_open = true,
        },
    },
}
  -- vim.g.nvim_tree_respect_buf_cwd = 1
end

return M
