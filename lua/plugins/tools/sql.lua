-- ============================================================
-- 数据库 UI（vim-dadbod + dadbod-ui）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
})

-- 基础行为
vim.g.db_ui_show_help = 0
vim.g.db_ui_auto_execute_table_helpers = 1 -- 自动执行查询助手（预览表数据等）
vim.g.db_ui_win_position = "right"
vim.g.db_ui_win_width = 35
vim.g.db_ui_disable_mappings = 0
vim.g.db_ui_show_database_icon = 1

-- 图标
vim.g.db_ui_icons = {
	expanded = {
		db = "▾ ",
		buffers = "▾ ",
		saved_queries = "▾ ",
		schemas = "▾ ",
		schema = "▾ פּ",
		tables = "▾ 󰙅",
		table = "▾ ",
	},
	collapsed = {
		db = "▸ ",
		buffers = "▸ ",
		saved_queries = "▸ ",
		schemas = "▸ ",
		schema = "▸ פּ",
		tables = "▸ 󰙅",
		table = "▸ ",
	},
	saved_query = "",
	new_query = "󰓰",
	tables = "",
	buffers = "",
	add_connection = "󱄀",
	connection_ok = "✓",
	connection_error = "✕",
}

-- ── 说明 ─────────────────────────────────────────────────
-- :DBUI              打开数据库侧边栏
-- :DBUIToggle        切换侧边栏显示
-- :DBUIAddConnection 添加新连接
--
-- MySQL 连接 URL 格式：
--   username:password@tcp(host)/database
--
-- PostgreSQL 连接 URL 格式：
--   postgresql://username:password@host/database
