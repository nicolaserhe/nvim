-- ============================================================
-- 插件加载入口
-- 启动时立即加载：UI、LSP、编辑器、必要工具
-- 懒加载：通过 util.lazy 在命令/按键/事件触发时才 require
-- ============================================================

local lazy = require("util.lazy")

-- ── UI 层（主题最先，避免颜色错乱） ──────────────────────
require("plugins.ui.theme")
require("plugins.ui.statusline")
require("plugins.ui.filetree") -- oil 配置很轻
require("plugins.ui.dashboard")
require("plugins.ui.git")
require("plugins.ui.trouble")
require("plugins.ui.render-markdown")

-- ── LSP 层 ───────────────────────────────────────────────
require("plugins.lsp.servers")
require("plugins.lsp.keymaps")
require("plugins.lsp.diagnostics")
require("plugins.lsp.highlight")
require("plugins.lsp.lazydev")
require("plugins.lsp.completion")

-- ── 编辑增强 ─────────────────────────────────────────────
require("plugins.editor.treesitter")
require("plugins.editor.textobjects")
require("plugins.editor.pairs")
require("plugins.editor.picker")
require("plugins.editor.whichkey")

-- ── 工具链：必须立即加载（mason 装包；format/lint/illuminate 已是事件触发；persistence 需挂 VimLeavePre）
require("plugins.tools.mason")
require("plugins.tools.format")
require("plugins.tools.lint")
require("plugins.tools.todo")
require("plugins.tools.test")
require("plugins.tools.persistence")
require("plugins.tools.ai.minuet") -- blink.cmp 注册了 minuet 源，需立即可 require

-- ── 懒加载：按需触发的重插件 ───────────────────────────────

-- toggleterm: 命令或快捷键触发
lazy.on_cmd("plugins.tools.toggleterm", {
	"ToggleTerm",
	"TermExec",
	"TermSelect",
	"ToggleTermToggleAll",
	"ToggleTermSendCurrentLine",
	"ToggleTermSendVisualLines",
	"ToggleTermSendVisualSelection",
})
lazy.on_keys("plugins.tools.toggleterm", {
	"<C-\\>",
	"<leader>1",
	"<leader>2",
	"<leader>3",
	"<leader>4",
	"<leader>5",
	"<leader>tt",
})

-- DAP: 仅在调试时加载
lazy.on_cmd("plugins.tools.dap", {
	"DapContinue",
	"DapStepOver",
	"DapStepInto",
	"DapStepOut",
	"DapBreakpoint",
	"DapBreakpointCondition",
	"DapTerminate",
	"DapREPL",
	"DapRunLast",
	"DapUIToggle",
	"DapEval",
})

-- dadbod: 仅使用数据库 UI 时加载
lazy.on_cmd("plugins.tools.sql", {
	"DBUI",
	"DBUIToggle",
	"DBUIAddConnection",
	"DBUIFindBuffer",
	"DBUIRenameBuffer",
})

-- grug-far: 仅项目级搜索替换时加载
lazy.on_cmd("plugins.tools.grug-far", {
	"GrugFar",
	"GrugFarVisual",
	"GrugFarWithin",
	"GrugFarWithinVisual",
})

-- claudecode: 仅与 Claude Code CLI 交互时加载
lazy.on_cmd("plugins.tools.ai.claudecode", {
	"ClaudeCode",
	"ClaudeCodeFocus",
	"ClaudeCodeStart",
	"ClaudeCodeStop",
	"ClaudeCodeStatus",
	"ClaudeCodeSend",
	"ClaudeCodeAdd",
	"ClaudeCodeTreeAdd",
	"ClaudeCodeDiffAccept",
	"ClaudeCodeDiffDeny",
})
