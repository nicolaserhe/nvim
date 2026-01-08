-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    -- { src = 'https://github.com/kndndrj/nvim-dbee' },
    { src = 'https://github.com/tpope/vim-dadbod' },
    { src = 'https://github.com/kristijanhusak/vim-dadbod-ui' },
}


-- =========================
-- Setup / Config
-- =========================
-- 基本设置
vim.g.db_ui_show_help = 0
vim.g.db_ui_auto_execute_table_helpers = 1 -- 自动执行查询助手
vim.g.db_ui_win_position = "right"
vim.g.db_ui_win_width = 35
vim.g.db_ui_disable_mappings = 0
vim.g.db_ui_show_database_icon = 1

-- 图标设置
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
-- require("dbee").setup {
--     -- 针对不同连接类型的额外表级辅助命令
--     -- 每个 helper 的值都是一个 go-template，
--     -- 可用变量包括：
--     -- "Table"、"Schema" 和 "Materialization"
--     extra_helpers = {
--         -- 示例：
--         -- ["mysql"] = {
--         --   ["列出全部"] = "select * from {{ .Table }}",
--         -- },
--     },
--
--     -- 抽屉（drawer）窗口配置
--     drawer = {
--         -- 是否禁用帮助提示
--         disable_help = true,
--     },
-- }


-- =========================
-- Help
-- =========================
-- mysql 连接的的 url 格式
-- "url": "username:password@tcp(host)/database-name"
