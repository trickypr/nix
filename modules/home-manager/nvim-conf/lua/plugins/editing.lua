return {
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

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettierd" },
				markdown = { "prettierd", "injected" },
				gleam = { "gleam" },
				nix = { "nixfmt" },
			},

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},

	-- TODO: Replace with blink
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Will be keeping these disabled for the moment with the goal of making
			-- sure other completion engines work well
			-- "hrsh7th/cmp-buffer"
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
		},

		config = function(_, opts)
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "path" },
				}),
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		opts = {
      -- stylua: ignore
			simple = {
				"dafny", "jsonls", "lua_ls", "elixirls", "elmls", "nil_ls", 
        "rust_analyzer", "gleam", "gopls", "pylsp", "pyright", "pylyzer", 
        "ts_ls", "clangd", "cssls", "html", "svelte", "typst_lsp", "templ",
        "vhdl_ls", "hls"
			},

			servers = {
				ltex = {
          -- stylua: ignore
					filetypes = {
						"bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", 
            "tex", "pandoc", "quarto", "rmd", "context", "html", "xhtml", 
            "mail", "text", 
          },
				},
			},
		},
		config = function(_, opts)
			local servers = opts.servers
			local simple = opts.simple

			for _, server in ipairs(simple) do
				require("lspconfig")[server].setup({})
			end

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
			{ "gr", vim.lsp.buf.references, desc = "Go to references" },
		},
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
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {},
	},
}
