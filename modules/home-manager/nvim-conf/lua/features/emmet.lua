local M = {}

local type_height = 1

local width = 40
local height = 10

function M.emmet(target)
	local target_buf = vim.api.nvim_get_current_buf()
	local target_loc = vim.api.nvim_win_get_cursor(0)

	local typing_buf = vim.api.nvim_create_buf(false, true)
	local result_buf = vim.api.nvim_create_buf(false, true)

	local ui = vim.api.nvim_list_uis()[1]

	local typing_win = vim.api.nvim_open_win(typing_buf, true, {
		relative = "editor",
		col = (ui.width / 2) - (width / 2),
		row = (ui.height / 2) - (height / 2 + 2),
		width = width,
		height = type_height,
		anchor = "NW",
		border = "single",
		style = "minimal",
	})

	local result_win = vim.api.nvim_open_win(result_buf, true, {
		relative = "win",
		win = typing_win,
		col = -1,
		row = 2,
		width = width,
		height = height,
		anchor = "NW",
		border = "single",
		style = "minimal",
	})

	vim.api.nvim_set_current_win(typing_win)

	local replacement = {}
	vim.api.nvim_create_autocmd({ "TextChangedI" }, {
		buffer = typing_buf,
		callback = function(ev)
			local text = vim.api.nvim_buf_get_lines(typing_buf, 0, 1, false)[1]
			local handle = io.popen("echo '" .. text .. "' | emmet-helper --target " .. target)
			local output = handle:read("*a")
			handle:close()
			replacement = vim.fn.split(output, "\n")
			vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, replacement)
		end,
	})

	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		buffer = typing_buf,
		callback = function(ev)
			vim.api.nvim_win_close(result_win, true)
		end,
	})

	vim.keymap.set({ "n", "v" }, "<C-CR>", function()
		vim.api.nvim_buf_set_text(target_buf, target_loc[1], target_loc[2], target_loc[1], target_loc[2], replacement)

		vim.api.nvim_win_close(typing_win, true)
		vim.api.nvim_win_close(result_win, true)
	end, { buffer = typing_buf })
end

return M
