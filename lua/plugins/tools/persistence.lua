-- ============================================================
-- 会话持久化（persistence.nvim）
-- 每个 cwd 一个 session，按需加载，无自动恢复打扰
-- 替代 neovim-session-manager
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/folke/persistence.nvim" },
})

require("persistence").setup({
	-- session 存储位置（默认 stdpath("state")/sessions）
	dir = vim.fn.stdpath("state") .. "/sessions/",
	-- 退出前清理非当前 cwd 的 buffer，避免会话保存无关文件
	pre_save = function()
		local cwd = vim.fn.getcwd()
		local cur_buf = vim.api.nvim_get_current_buf()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if not vim.api.nvim_buf_is_loaded(buf) then
				goto continue
			end
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" and buf ~= cur_buf and not vim.startswith(name, cwd) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
			::continue::
		end
	end,
	-- 空 session 不保存
	save_empty = false,
})

-- ── User commands ──────────────────────────────────────────
local persistence = require("persistence")

vim.api.nvim_create_user_command("PersistenceLoad", function()
	persistence.load()
end, { desc = "Load session for current cwd" })

vim.api.nvim_create_user_command("PersistenceLoadLast", function()
	persistence.load({ last = true })
end, { desc = "Load last session (across cwds)" })

vim.api.nvim_create_user_command("PersistenceSelect", function()
	persistence.select()
end, { desc = "Pick a session via vim.ui.select" })

vim.api.nvim_create_user_command("PersistenceSave", function()
	persistence.save()
end, { desc = "Manually save current session" })

vim.api.nvim_create_user_command("PersistenceStop", function()
	persistence.stop()
end, { desc = "Stop auto-saving on VimLeavePre" })

-- ── 用法 ──────────────────────────────────────────────────
-- :PersistenceLoad        加载当前 cwd 的 session
-- :PersistenceLoadLast    加载最近一次（不限 cwd）
-- :PersistenceSelect      vim.ui.select 选择 session
-- :PersistenceSave        手动保存
-- :PersistenceStop        本次退出不自动保存（保留旧 session）
