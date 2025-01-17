vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

vim.o.smartindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

vim.o.timeout = true
vim.o.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.o.colorcolumn = "80"

vim.wo.number = true
vim.wo.relativenumber = true

vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"))
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"))

vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"))
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"))

require("lazy").setup({
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "<leader> ", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
			{ "<leader>-", "<cmd>split<cr>", desc = "Split down" },
			{
				"<leader>[e",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "Go to last error",
			},
			{ "<leader>]e", diagnostic_goto(true, "ERROR"), desc = "Go to next error" },
			{ "<leader>[e", diagnostic_goto(false, "ERROR"), desc = "Go to next error" },
			{
				"<leader>ca",
				function()
					require("tiny-code-action").code_action()
				end,
				desc = "Code action",
			},
			{ "<leader>e", "<cmd>Explore<cr>", desc = "Explore containing folder" },
			{ "<leader>|", "<cmd>vsplit<cr>", desc = "Split right" },
			{
				"<leader>?",
				function()
					require("which-key").show()
				end,
				"Buffer local keymaps (which-key)",
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				search = { enable = true },
				char = { jump_label = true },
			},
		},
	},
	{
		"ahmedkhalf/project.nvim",
		opt = {
			manual_mode = true,
		},
	},
	{ "folke/neoconf.nvim", cmd = "Neoconf" },

	{
		"echasnovski/mini.pairs",
		version = false,
		config = true,
		name = "mini.pairs",
	},
	{
		"echasnovski/mini.surround",
		version = false,
		config = true,
		name = "mini.surround",
	},

	-- UI changes
	{ -- Tabline stuff
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			presets = {
				inc_rename = true,
				command_palette = true,
				lsp_doc_border = true,
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		opts = { render = "compact", top_down = false },
	},

	{ -- Theme
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			flavour = "latte",
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- Library items can be absolute paths
				-- "~/projects/my-awesome-lib",
				-- Or relative, which means they will be resolved as a plugin
				-- "LazyVim",
				-- When relative, you can also provide a path to the library in the plugin dir
				-- "luvit-meta/library", -- see below
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		opts = {
			servers = {
				dafny = {},
				jsonls = {},
				lua_ls = {},
				elixirls = {},
				elmls = {},
				nil_ls = {}, -- Nixos
				rust_analyzer = {},
				gleam = {},
				gopls = {},
				pylsp = {},
				pyright = {},
				pylyzer = {},
				ts_ls = {},
				clangd = {},
				cssls = {},
				html = {},
				svelte = {},
				typst_lsp = {},
				templ = {},
				ltex = {
					filetypes = {
						"bib",
						"gitcommit",
						"markdown",
						"org",
						"plaintex",
						"rst",
						"rnoweb",
						"tex",
						"pandoc",
						"quarto",
						"rmd",
						"context",
						"html",
						"xhtml",
						"mail",
						"text",
						"typst",
					},
				},
				qmlls = {},
				vhdl_ls = {},
				hls = {},
			},
		},
		---@param opts PluginLspOpts
		config = function(_, opts)
			local servers = opts.servers

			for server, server_opts in pairs(servers) do
				if server_opts then
					require("lspconfig")[server].setup(server_opts)
				end
			end
		end,
		keys = {
			{ "gd", vim.lsp.buf.definition, desc = "Go to definition" },
			{ "gD", vim.lsp.buf.declaration, desc = "Go to declaration" },
			{ "gy", vim.lsp.buf.type_definition, desc = "Go to type definition" },
		},
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths in commands
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- for lua autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets library
			"onsails/lspkind.nvim", -- vs-code like pictograms
		},

		config = function(_, opts)
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
				}),
				-- configure lspkind for vs-code like pictograms in completion menu
				formatting = {
					format = lspkind.cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})
		end,
	},
	{
		"smjonas/inc-rename.nvim",
		config = true,
		keys = {
			{
				"<leader>cr",
				function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end,
				desc = "Rename symbol",
				expr = true,
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "injected" },
				gleam = { "gleam" },
				nix = { "nixfmt" },
			},

			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},

	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"rachartier/tiny-code-action.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
		},
		event = "LspAttach",
		opts = {},
	},

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
		event = "VeryLazy",
		keys = {
			{ "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
			{ "<leader>pg", "<cmd>Telescope live_grep<cr>", desc = "Find Files (Root Dir)" },
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
			},
			{
				"<leader>h",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
			},
			{
				"<C-S-J>",
				function()
					require("harpoon"):list():prev()
				end,
			},
			{
				"<C-S-K>",
				function()
					require("harpoon"):list():next()
				end,
			},
		},
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		keys = {
			{
				"<leader>pr",
				'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
				desc = "Find and replace (word)",
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"elixir",
					"heex",
					"javascript",
					"html",
					"gleam",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
})
