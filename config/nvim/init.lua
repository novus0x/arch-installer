vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
    		"clone",
    		"--filter=blob:none",
    		"https://github.com/folke/lazy.nvim.git",
    		"--branch=stable",
    		lazypath,
  	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- UI
	"nvim-lualine/lualine.nvim", "nvim-tree/nvim-web-devicons", { "folke/tokyonight.nvim", lazy = false, priority = 1000 },

  	-- File explorer
  	"nvim-tree/nvim-tree.lua",
  
	-- Git
  	"lewis6991/gitsigns.nvim", "tpope/vim-fugitive",

  	-- LSP + Autocompletion
  	"neovim/nvim-lspconfig", "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "onsails/lspkind.nvim",

  	-- Autopairs
  	"windwp/nvim-autopairs",

	-- Telescope
  	"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim",
  
	-- Syntax Highlighting
  	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
})

-- 2. Settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.cmd.colorscheme("tokyonight")

-- 3. Lualine
require("lualine").setup {
	options = {
    		theme = "tokyonight",
    		icons_enabled = true
  	}
}

-- 4. Nvim Tree
require("nvim-tree").setup()
vim.keymap.set('n', '<leader>e', ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- 5. Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

-- 6. Treesitter
require('nvim-treesitter.configs').setup {
	ensure_installed = { "lua", "python", "c", "cpp", "bash", "json" },
  	highlight = {
    	enable = true
  	},
}

-- 7. LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.lua_ls.setup { capabilities = capabilities }

-- 8. Autocompletion
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	formatting = {
    		format = lspkind.cmp_format({
      			mode = "symbol_text",
      			maxwidth = 50,
   		})
  	},
  	snippet = {
    		expand = function(args)
      		require("luasnip").lsp_expand(args.body)
    		end,
 	},
  	mapping = cmp.mapping.preset.insert({
    		['<C-Space>'] = cmp.mapping.complete(),
    		['<CR>'] = cmp.mapping.confirm({ select = true }),
 	}),
  	sources = cmp.config.sources({
    		{ name = "nvim_lsp" },
    		{ name = "luasnip" },
  	})
})

-- 9. Autopairs
require("nvim-autopairs").setup {}

-- 10. Git signs
require("gitsigns").setup {}

-- Leader key
vim.g.mapleader = " "

