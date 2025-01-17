-- Fancy viewers for specific file types

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependancies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		ft = "markdown",
		--- @module 'render-markdown'
		--- @type render.md.UserConfig
		opts = {},
	},
}
