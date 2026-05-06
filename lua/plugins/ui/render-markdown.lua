-- ============================================================
-- render-markdown.nvim：在 buffer 里直接渲染 markdown
-- 标题彩色背景、代码块边框、列表 bullet、表格对齐、checkbox ☐/☑
-- 编辑当前行时自动显示原始 markdown 语法（anti-conceal）
--
-- 依赖 markdown + markdown_inline parser
-- markdown_inline 通过 languages.lua 的 treesitter_extra_parsers 自动安装
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

require("render-markdown").setup({
	-- 默认 file_types = { "markdown", "Avante", "codecompanion" }
	-- 不需要主动加 claudecode（claudecode 走 terminal，render-markdown 不参与）
})

-- ── 用法 ──────────────────────────────────────────────────
-- :RenderMarkdown                  toggle 全局渲染开关
-- :RenderMarkdown enable           开启
-- :RenderMarkdown disable          关闭
-- :RenderMarkdown buf_enable       仅当前 buffer 开启
-- :RenderMarkdown buf_disable      仅当前 buffer 关闭
-- :RenderMarkdown buf_toggle       仅当前 buffer toggle
-- :RenderMarkdown log              打开调试日志
--
-- 行为：
--   光标停在某行时，那行临时显示原始 markdown 语法（不渲染），其他行渲染。
--   适合在「写」与「看」之间无缝切换，无需手动 toggle。
