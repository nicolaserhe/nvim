-- ============================================================
-- Tonsky 规则 × Dracula 调色板
-- 详细规则见 ~/.claude/projects/-home-gcy--config-nvim/memory/user_highlight_rules.md
--
-- ┌────────────────────────────┬──────────┬────────────────────┐
-- │ 角色                       │ 色码     │ Dracula 官方名     │
-- ├────────────────────────────┼──────────┼────────────────────┤
-- │ 字符串 + 数字字面量        │ #50FA7B  │ Green              │
-- │ 注释                       │ #F1FA8C  │ Yellow             │
-- │ 定义点（func/type/var/参数/field）│ #8BE9FD  │ Cyan         │
-- │ 内建常量（nil/true/false/NULL/nullptr）│ #BD93F9  │ Purple   │
-- │ 标点 + 所有运算符（dim）   │ #7C89B6  │ Comment 提亮版     │
-- │ 其他（关键字/变量使用/调用）│ #F8F8F2  │ Foreground         │
-- └────────────────────────────┴──────────┴────────────────────┘
--
-- 反规则：不染关键字、变量使用、函数调用；不用 bold / italic。
-- 仅 go / c / cpp 生效（window-local highlight namespace）。
-- ============================================================

local M = {}

-- ── 适用的 filetype ────────────────────────────────────────
local TONSKY_FILETYPES = { go = true, c = true, cpp = true }

-- ── Dracula 调色板 × Tonsky 角色 ───────────────────────────
local STRING_NUM = "#50FA7B" -- Dracula Green       字符串 + 数字字面量
local COMMENT = "#F1FA8C" -- Dracula Yellow      注释
local DEFINITION = "#8BE9FD" -- Dracula Cyan        所有定义点
local CONSTANT = "#BD93F9" -- Dracula Purple      内建常量
local PUNCT_DIM = "#7C89B6" -- Dracula Comment 提亮版（原 #6272A4 在深色 bg 上对比度不足）
local BASE_FG = "#F8F8F2" -- Dracula Foreground  关键字 / 变量使用 / 调用

-- ── 命名空间：仅 window-local 应用 ─────────────────────────
local ns = vim.api.nvim_create_namespace("tonsky_highlights")

local function define()
	local set = function(group, attrs)
		vim.api.nvim_set_hl(ns, group, attrs)
	end

	-- ── 1. 字符串 + 数字 → 绿 ─────────────────────────
	for _, g in ipairs({
		"@string",
		"@string.escape",
		"@string.special",
		"@string.regexp",
		"@string.documentation",
		"@character",
		"@character.special",
		"@number",
		"@number.float",
	}) do
		set(g, { fg = STRING_NUM })
	end

	-- ── 2. 注释 → 黄（亮，无斜体） ────────────────────
	set("@comment", { fg = COMMENT })
	set("@comment.documentation", { fg = COMMENT })

	-- ── 3. 所有定义点 → 青（无粗体） ──────────────────
	for _, g in ipairs({
		"@function",
		"@function.method",
		"@type",
		"@type.definition",
		"@variable.definition",
		"@variable.parameter",
	}) do
		set(g, { fg = DEFINITION })
	end

	-- ── 4. 内建常量 → 紫 ──────────────────────────────
	-- 注意：@constant（用户定义常量的使用位置）走 base，仅 builtin 染色
	set("@constant.builtin", { fg = CONSTANT })
	set("@boolean", { fg = CONSTANT })

	-- ── 5. 标点 + 运算符 → dim 灰 ─────────────────────
	-- 标点（含 = / := 在 scm 里重分类到 @punctuation.delimiter）
	-- 运算符（+ - * / == && 等）也归 dim：Tonsky 思路是把所有「语法骨架」
	-- 统一弱化，让真正的名字（标识符）凸显
	set("@punctuation.bracket", { fg = PUNCT_DIM })
	set("@punctuation.delimiter", { fg = PUNCT_DIM })
	set("@punctuation.special", { fg = PUNCT_DIM })
	set("@operator", { fg = PUNCT_DIM })

	-- ── 6. 强制 base（关键反规则：使用位置 / 关键字 / 运算符 不染） ──
	for _, g in ipairs({
		-- 函数调用 / 方法调用（区别于 @function 定义点）
		"@function.call",
		"@function.method.call",
		-- 关键字
		"@keyword",
		"@keyword.operator",
		"@keyword.return",
		"@keyword.conditional",
		"@keyword.repeat",
		"@keyword.import",
		"@keyword.function",
		"@keyword.type",
		"@keyword.modifier",
		"@keyword.coroutine",
		"@keyword.directive",
		"@keyword.directive.define",
		"@keyword.exception",
		"@conditional",
		"@repeat",
		-- 变量 / 字段 / 属性 的「使用」位置
		"@variable",
		"@variable.builtin", -- this/self/__func__ 等
		"@field",
		"@property",
		-- 内建类型（int/void/bool 等系统类型，base）
		"@type.builtin",
		-- 用户定义常量的「使用」位置（注意：@constant.builtin 在第 4 节单独染紫）
		"@constant",
	}) do
		set(g, { fg = BASE_FG })
	end
end

-- ── 按 filetype 切换 window-local namespace ─────────────────
local function attach_to_current_window()
	local win = vim.api.nvim_get_current_win()
	local ft = vim.bo.filetype
	if TONSKY_FILETYPES[ft] then
		vim.api.nvim_win_set_hl_ns(win, ns)
	else
		vim.api.nvim_win_set_hl_ns(win, 0) -- 0 = 默认全局 ns
	end
end

--- 应用自定义高亮规则
--- 由 plugins/editor/treesitter.lua 的 ColorScheme autocmd 触发
function M.apply()
	define()

	local group = vim.api.nvim_create_augroup("TonskyHighlights", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinEnter" }, {
		group = group,
		callback = attach_to_current_window,
	})

	-- 立即应用到当前窗口
	attach_to_current_window()
end

return M
