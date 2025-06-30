local function plugin_path(name)
  return vim.fn.stdpath("data") .. "/nix-plugin-sources/" .. name
end

vim.opt.rtp:prepend(plugin_path("lazy.nvim"))

require("lazy").setup({
  spec = {
    {
      dir = plugin_path("oil.nvim"),
      opts = {},
      dependencies = {
        dir = plugin_path("mini.icons"),
        opts = {},
      },
    },

    {
      dir = plugin_path("mini.surround"),
      opts = {},
    },

    {
      dir = plugin_path("telescope.nvim"),
      opts = {},
      dependencies = {
        { dir = plugin_path("plenary.nvim") },
        { dir = plugin_path("telescope-fzf-native.nvim") },
      }
    }
  },
  checker = { enabled = false },
})

vim.cmd.colorscheme("habamax")

vim.g.mapleader = " "

vim.opt.confirm = true
vim.opt.list = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.scrolloff = 5
vim.opt.linebreak = true
vim.opt.laststatus = 3
vim.opt.ignorecase = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.smartcase = true
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.winminwidth = 5
vim.opt.wrap = false
