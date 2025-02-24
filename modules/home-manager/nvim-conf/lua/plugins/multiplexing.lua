-- Navigation and creating neovim workspaces

local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

-- Make the terminal multiplexing behave in a way that I like
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

return {
	{
		"folke/flash.nvim",
		opts = {
			modes = { char = { jump_labels = true } },
		},
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

	-- Technically not a navigation plugin, but this is where I am going to put all of my navigation key bindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			-- Multiplexing
			{ "<leader>-", "<cmd>split<cr>", desc = "Split down" },
			{ "<leader>|", "<cmd>vsplit<cr>", desc = "Split right" },

			-- Utility triggers
			{ "<leader>e", "<cmd>Explore<cr>", desc = "Explore containing folder" },
			{ "<leader>T", "<cmd>terminal<cr>", desc = "Open terminal in buffer" },

			{
				"<leader>ca",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "Go to last error",
			},
			{ "<leader>]e", diagnostic_goto(true, "ERROR"), desc = "Go to next error" },
			{ "<leader>[e", diagnostic_goto(false, "ERROR"), desc = "Go to prev error" },
			{ "<leader>]w", diagnostic_goto(true, "WARN"), desc = "Go to next warning" },
			{ "<leader>[w", diagnostic_goto(false, "WARN"), desc = "Go to prev warning" },

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
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
}
