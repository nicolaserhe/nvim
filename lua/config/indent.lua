-- ============================================================
-- 缩进模式配置（按 languages.lua 的 indent_mode 字段分组应用）
-- 从 plugins/editor/treesitter.lua 抽出，关注点分离：
--   treesitter.lua 只负责 TS 安装与高亮
--   indent.lua 只负责按文件类型设置缩进
-- ============================================================

local languages = require("config.languages")
local indent_groups = languages.get_langs_by_indent_mode()

-- ── cindent（C 系语言） ───────────────────────────────────
if #indent_groups.cindent > 0 then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = indent_groups.cindent,
		callback = function()
			vim.bo.cindent = true
		end,
	})
end

-- ── smartindent ──────────────────────────────────────────
if #indent_groups.smartindent > 0 then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = indent_groups.smartindent,
		callback = function()
			vim.bo.smartindent = true
		end,
	})
end

-- ── autoindent（settings.lua 已全局启用，此处只关掉其他模式） ──
if #indent_groups.autoindent > 0 then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = indent_groups.autoindent,
		callback = function()
			vim.bo.cindent = false
			vim.bo.smartindent = false
		end,
	})
end

-- ── treesitter 缩进（需对应 indents.scm） ─────────────────
if #indent_groups.treesitter > 0 then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = indent_groups.treesitter,
		callback = function()
			vim.bo.indentexpr = "v:lua.vim.treesitter.get_indent()"
		end,
	})
end
