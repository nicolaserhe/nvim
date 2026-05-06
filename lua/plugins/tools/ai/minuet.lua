-- ============================================================
-- minuet-ai：行内 ghost text 补全（接 Deepseek API）
-- 替代 copilot.lua，走自购的 LLM API
--
-- 必备：环境变量 DEEPSEEK_API_KEY
-- 未设置时：完全不启动（不 pack.add / 不 setup / 不进 blink 源），保持安静；
-- 但仍注册 :MinuetToggle 用于显式报错——用户主动调用时给清晰提示。
-- ============================================================

if (vim.env.DEEPSEEK_API_KEY or "") == "" then
	vim.api.nvim_create_user_command("MinuetToggle", function()
		error("DEEPSEEK_API_KEY is not set. Please export it and restart nvim to enable minuet ghost text.")
	end, { desc = "Toggle minuet ghost text（当前未设置 DEEPSEEK_API_KEY）" })
	return
end

vim.pack.add({
	{ src = "https://github.com/milanglacier/minuet-ai.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("minuet").setup({
	provider = "openai_compatible",

	provider_options = {
		openai_compatible = {
			end_point = "https://api.deepseek.com/v1/chat/completions",
			api_key = "DEEPSEEK_API_KEY", -- 环境变量名，运行时由 minuet 读取
			name = "Deepseek",
			model = "deepseek-chat",
			optional = {
				stop = nil,
				max_tokens = 256,
			},
		},
	},

	-- ── 行内 ghost text 模式 ───────────────────────────────
	virtualtext = {
		auto_trigger_ft = { "*" }, -- 所有文件类型自动触发
		auto_trigger_ignore_ft = { "TelescopePrompt", "snacks_picker_input", "alpha", "starter", "oil" },

		keymap = {
			accept = "<A-y>", -- 接受全部
			accept_line = "<A-l>", -- 接受单行
			prev = "<A-[>",
			next = "<A-]>",
			dismiss = "<A-e>",
		},
	},

	-- 性能/行为
	context_window = 16000,
	throttle = 1500, -- ms，键入间隔触发节流
	debounce = 400, -- ms，键入抖动等待
	request_timeout = 4, -- 秒
	notify = "warn", -- 仅在 warn/error 才通知
})

-- 切换 minuet 自动触发的命令（手动开关 ghost text）
vim.api.nvim_create_user_command("MinuetToggle", function()
	require("minuet.virtualtext").action.toggle()
end, { desc = "Toggle minuet ghost text auto-trigger" })

-- ── 快捷键说明（仅 minuet 行内补全相关） ────────────────────
-- <A-y>  接受补全建议（全部）
-- <A-l>  仅接受一行
-- <A-]>  下一个候选
-- <A-[>  上一个候选
-- <A-e>  关闭当前建议
-- :MinuetToggle  开关自动 ghost text
