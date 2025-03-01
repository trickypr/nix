-- Make it look pretty and consistent

return {
	{
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
		},
	},

	{
		"folke/snacks.nvim",
		lazy = false,
		--- @class snacks.Config
		opts = {
			dim = {
				animate = { enabled = true },
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})

			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.javacc = {
				install_info = {
					url = "~/Code/java/tree-sitter-javacc", -- local path or git repo
					files = { "src/parser.c", "src/scanner.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
					-- optional entries:
					branch = "main", -- default branch in case of git repo if different from master
					generate_requires_npm = false, -- if stand-alone parser without npm dependencies
				},
			}
		end,
	},
}
