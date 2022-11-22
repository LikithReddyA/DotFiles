local api = vim.api
local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = " "
g.maplocalleader = " "

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.updatetime = 250
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.cmdheight = 1
opt.laststatus = 3
opt.breakindent = true --Enable break indent
opt.undofile = true --Save undo history
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.ignorecase = true --Case insensitive searching unless /C or capital in search
opt.smartcase = true -- Smart case
opt.termguicolors = true -- Enable colors in terminal
-- Number of screen lines to keep above and below the cursor
opt.scrolloff = 8

opt.splitbelow = true --Split the window horizontally in below
opt.splitright = true -- Split the window vertically in right

-- Time in milliseconds to wait for a mapped sequence to complete.
opt.timeoutlen = 300

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Adding configuration for clipboard managing
vim.cmd [[autocmd VimLeave * call system("echo -n $'" . escape(getreg(),"'" . "' | xsel ]] --input --clipbard"))

-- we add the following lines to remove the /usr/include folder from the search and add all subdirectories in the current folder to the search.
opt.path:remove "/usr/include"
opt.path:append "**"
opt.wildignorecase = true -- To perform caseinsensitive search
opt.wildignore:append "**/.git/*" -- To ignore .git folder while searching

