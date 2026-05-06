-- ============================================================
-- 全局自动命令
-- ============================================================

-- 恢复上次光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lines = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lines then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})
