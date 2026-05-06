-- ============================================================
-- trouble.nvim v3：统一的列表面板 UI
-- 用于诊断 / LSP 引用定义 / symbols / quickfix / loclist / TODO
-- 与 fzf-lua 互补：trouble 是常驻面板（按文件分组浏览），fzf-lua 是一次性 picker
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/folke/trouble.nvim" },
})

require("trouble").setup({
	-- 默认即可。常用可调项：
	--   focus = false       打开后焦点不切到 trouble 窗口
	--   auto_close = true   列表清空时自动关闭
	--   modes = { ... }     自定义视图（如把某个 mode 预设过滤器）
})

-- ── 用法 ──────────────────────────────────────────────────
-- 命令格式：:Trouble <mode> [action] [opts]
-- 默认 action 为 toggle（再次执行同模式即关闭）
--
--   :Trouble diagnostics                    全工作区诊断
--   :Trouble diagnostics filter.buf=0       仅当前 buffer 诊断
--   :Trouble symbols                        document symbols 树形大纲
--   :Trouble lsp                            LSP 综合面板（refs/defs/...）
--   :Trouble lsp_references                 LSP 引用
--   :Trouble lsp_definitions                LSP 定义
--   :Trouble lsp_implementations            LSP 实现
--   :Trouble lsp_type_definitions           LSP 类型定义
--   :Trouble lsp_incoming_calls             被调用位置
--   :Trouble lsp_outgoing_calls             调用了哪些
--   :Trouble qflist                         接管 quickfix
--   :Trouble loclist                        接管 location list
--   :TodoTrouble                            来自 todo-comments 集成
--
-- 面板内默认 keymap：
--   <CR>      跳到该项
--   o         跳过去并关闭面板
--   <C-x>/<C-v>/<C-t>  水平/垂直/tab 打开
--   q         关闭
--   r         刷新
--   ?         帮助
--
-- 已透明接管 :Diagnostics project / buffer（见 lsp/diagnostics.lua）
