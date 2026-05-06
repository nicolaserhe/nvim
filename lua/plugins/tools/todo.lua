-- ============================================================
-- TODO/FIXME/HACK 等关键词高亮 + 项目级搜索（todo-comments.nvim）
-- 依赖 plenary（minuet 已加载，此处显式声明保证自洽；vim.pack 幂等）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("todo-comments").setup({
	signs = true, -- gutter 显示 sign
	highlight = {
		keyword = "wide", -- 高亮整个 KEYWORD: 段（含冒号）
		comments_only = true, -- 仅在注释里识别（避免字符串误判）
	},
	-- 默认关键词已覆盖 TODO/FIX(BUG/FIXME/ISSUE)/HACK/WARN(XXX)/PERF/NOTE(INFO)/TEST
	-- 如需自定义关键词，在 keywords = { ... } 表里加
})

-- ── 用法 ──────────────────────────────────────────────────
-- :TodoFzfLua              fzf-lua 搜索全部 TODO（推荐）
-- :TodoFzfLua keywords=TODO,FIX
--                          按关键词过滤
-- :TodoQuickFix            列出全部 TODO 到 quickfix（:cnext/:cprev 跳转）
-- :TodoLocList             同上，进 location list
--
-- 默认识别关键词（含别名 / 颜色 icon / 语义）
--   FIX  (FIXME, BUG, FIXIT, ISSUE)        红 bug    已知 bug 或必须修复的代码，比 TODO 紧急
--   TODO                                    蓝 check  待办 / 待实现，最通用的标记
--   HACK                                    黄 zap    临时绕过 / 不优雅方案，提醒后人此处有妥协
--   WARN (WARNING, XXX)                     橙 warn   警告 / 陷阱提醒，读到此处要小心
--   PERF (OPTIM, PERFORMANCE, OPTIMIZE)     紫 dance  性能相关备注，可能的优化点或瓶颈
--   NOTE (INFO)                             绿 info   重要上下文 / 给后续读者的说明
--   TEST (TESTING, PASSED, FAILED)          灰 check  测试相关 / 临时调试代码标记
--
-- 不绑 keymap（按用户偏好走命令）；如需 motion 后续可在此加 ]o/[o
