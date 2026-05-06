-- ============================================================
-- claudecode.nvim：与 Claude Code CLI 双向通信
-- nvim 作为 Claude Code 的 IDE 端：发选区、加 buffer、接 diff
--
-- 依赖：系统已装 Claude Code CLI（~$ which claude）
-- auth 走 CLI 端，不消耗 nvim 侧 API key
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/coder/claudecode.nvim" },
	-- folke/snacks.nvim 是可选 terminal 后端，不装也能用 native terminal
})

require("claudecode").setup({
	-- 默认即可，详见 :help claudecode
	-- terminal_cmd 由 claudecode 自动检测 `claude` 命令
})

-- ── 常用 user command ─────────────────────────────────────
-- :ClaudeCode               切换 Claude Code 浮动终端窗口
-- :ClaudeCodeFocus          focus 到 Claude 终端
-- :ClaudeCodeStart          启动 Claude Code 实例（若未启动）
-- :ClaudeCodeStop           停止 Claude Code 实例
-- :ClaudeCodeStatus         查看连接状态
-- :ClaudeCodeSend           发送可视选区到 Claude 上下文
-- :ClaudeCodeAdd <file>     把文件加进 Claude 上下文
-- :ClaudeCodeTreeAdd        把当前文件树选中节点加进上下文
-- :ClaudeCodeDiffAccept     接受当前打开的 diff
-- :ClaudeCodeDiffDeny       拒绝当前打开的 diff
