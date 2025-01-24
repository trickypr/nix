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

	{
		"saghen/blink.cmp",
		version = "0.10.0",

		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			completion = {
				accept = { auto_brackets = { enabled = true } },
				documentation = {
					auto_show = true,
				},
				ghost_text = { enabled = true },
			},
		},
		opts_extend = { "sources.default" },
	},

	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			-- "hrsh7th/cmp-nvim-lsp",
		},
		opts = {
      -- stylua: ignore
			simple = {
				"dafny", "jsonls", "lua_ls", "elixirls", "elmls", "nil_ls",
        "rust_analyzer", "gleam", "gopls", "pylsp", "pyright", "pylyzer",
        "ts_ls", "clangd", "cssls", "html", "svelte", "tinymist", "templ",
        "vhdl_ls", "hls"
			},

			--- @module 'lspconfig.configs'
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

			vim.lsp.inlay_hint.enable()
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
