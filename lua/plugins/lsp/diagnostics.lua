-- ============================================================
-- 诊断显示与命令
-- ============================================================
vim.diagnostic.config({
	virtual_text = true, -- 行尾显示诊断文字
	underline = true, -- 问题处加下划线
	update_in_insert = false, -- 插入模式下暂停刷新，减少干扰
})

-- :Diagnostics              → 光标处诊断浮窗（默认）
-- :Diagnostics buffer       → 当前 buffer 诊断（trouble 面板）
-- :Diagnostics project      → 全工作区诊断（trouble 面板）
vim.api.nvim_create_user_command("Diagnostics", function(cmd)
	local scope = cmd.args
	if scope == "project" then
		require("trouble").open({ mode = "diagnostics" })
	elseif scope == "buffer" then
		require("trouble").open({ mode = "diagnostics", filter = { buf = 0 } })
	else
		vim.diagnostic.open_float()
	end
end, {
	nargs = "?",
	complete = function()
		return { "buffer", "project" }
	end,
	desc = "Show diagnostics: project / buffer (trouble) / cursor (default float)",
})
