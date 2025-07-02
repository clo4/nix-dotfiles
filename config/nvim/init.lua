vim.cmd.colorscheme("gruvbox-material")

vim.g.mapleader = " "

-- Uses ripgrep for grep
vim.opt.grepprg = "rg --vimgrep"

-- How long before the swap file is written to?
vim.opt.updatetime = 200

-- Makes visual block mode able to select empty space
vim.opt.virtualedit = "block"

-- TODO: Find out more about this option
vim.opt.wildmode = "longest:full,full"

-- Absolute line number with relative numbers above/below
vim.opt.number = true
vim.opt.relativenumber = true

-- Set highlight on search
vim.opt.hlsearch = false

-- Substitute always uses global flag
vim.opt.gdefault = true

-- Enable mouse mode
vim.opt.mouse = "a"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set colorscheme
vim.opt.termguicolors = true
vim.g.gruvbox_material_enable_italic = 0
vim.g.gruvbox_material_disable_italic_comment = 1
vim.g.gruvbox_material_sign_column_background = "none"
vim.g.gruvbox_material_palette = "original"
vim.cmd([[colorscheme gruvbox-material]])

-- Set completeopt to have a better completion experience
vim.opt.completeopt = { "menuone", "noselect" }

-- Show line and col
vim.opt.ruler = true

-- Show certain hidden characters
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", lead = "·", trail = "·", nbsp = "•" }

-- Delete comment characters when joining lines
vim.opt.formatoptions:append("j")

-- Recognize numbered lists
vim.opt.formatoptions:append("n")

-- Read changes from disk
vim.opt.autoread = true

-- Highlight the line with the cursor on it
vim.opt.cursorline = true

-- Sane line wrapping settings
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showbreak = "↪"
vim.opt.breakindent = true
vim.opt.breakindentopt = "list:-1"

-- Sane tab settings
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0

-- Splits will open on the right/below instead of left/above
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"

-- Vertical diffs
vim.opt.diffopt:append("vertical")

-- 3 lines/cols buffer when scrolling
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3

-- Always draw the sign column
vim.opt.signcolumn = "yes"

-- Wait 300ms for a sequence to complete
vim.opt.timeout = true
vim.opt.timeoutlen = 300

-- Ignore files matching these patterns while expanding a wildcard
vim.opt.wildignore = { "*.o", "*.obj", "*.bak", "*.exe", "*.pyc", ".DS_Store" }

-- Hide the welcome message
vim.opt.shortmess = "I"

-- Ask to write instead of failing when using :q
vim.opt.confirm = true

-- Use tree-sitter folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevelstart = 69

-- Display a window title
vim.opt.title = true

-- Use the + register for operations that would normally use _
vim.opt.clipboard = "unnamedplus"

-- Don't display the ~ chars at the end of the buffer
vim.opt.fillchars = { eob = " " }

--

-- Highlight the yanked region briefly
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", {
	clear = true,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- If the file's parent directory doesn't exist, create it first
local mkdirp_on_write = vim.api.nvim_create_augroup("MkdirpOnWrite", {
	clear = true,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
	group = mkdirp_on_write,
	pattern = "*",
})


vim.api.nvim_create_user_command("Term", ":vsp | terminal", { desc = "Open a new terminal in a split" })


-- Make Y behave consistently, like D and C
vim.keymap.set("n", "Y", "y$", { silent = true })

-- Paste without overwriting the unnamed register
vim.keymap.set("v", "P", '"_dP', { silent = true })

-- dD deletes all the characters in the line without removing the line itself
vim.keymap.set("n", "dD", "0D", { desc = "Delete all the characters in the line" })

-- Space does nothing in normal or visual mode
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Up and down navigate through wrapped lines sensibly
vim.keymap.set("n", "<up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Delete a buffer without deleting the split
vim.keymap.set("n", "<leader>bd", "<cmd>bp|bd #<cr>", { desc = "Delete buffer without closing pane" })

-- Telescope mappings
vim.keymap.set("n", "<leader>f", require("telescope.builtin").find_files, { desc = "Find files by name" })
vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "Find files with grep" })
vim.keymap.set("n", "<leader>b", require("telescope.builtin").buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>d", require("telescope.builtin").diagnostics, { desc = "Find diagnostics" })
vim.keymap.set("n", "<leader>o", require("telescope.builtin").jumplist, { desc = "View jumplist" })

-- Diagnostic pairs
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "dn", vim.diagnostic.goto_next)
vim.keymap.set("n", "dp", vim.diagnostic.goto_prev)

-- View diagnostic information
vim.keymap.set("n", "ge", vim.diagnostic.open_float)

-- Hit escape twice to exit the terminal
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

require("mini.surround").setup()

require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})
require("telescope").load_extension("fzf")
--require("telescope").load_extension("ui-select")
