-- ============================================================
-- 调试器（nvim-dap + dap-ui + dap-virtual-text）
-- 各语言 adapter 由 languages.lua 的 dap 字段驱动；新增语言只需在
-- LANGUAGES 里加 dap = { adapter, mason, helper? }，本文件无需改动
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },
})

local dap = require("dap")
local dapui = require("dapui")
local languages = require("config.languages")

dapui.setup({})
require("nvim-dap-virtual-text").setup({})

-- ============================================================
-- 按 languages.lua 的 dap 字段循环注册各语言 adapter
-- ============================================================
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local helper_inited = {} -- 避免重复 setup（go 一般只一个 entry，但保险起见）

for _, dap_config in pairs(languages.get_dap_configs()) do
	if dap_config.helper == "dap-go" and not helper_inited["dap-go"] then
		require("dap-go").setup({})
		helper_inited["dap-go"] = true
	elseif dap_config.helper == "dap-python" and not helper_inited["dap-python"] then
		-- mason 安装路径：~/.local/share/nvim/mason/packages/debugpy/venv/bin/python
		require("dap-python").setup(mason_packages .. "/debugpy/venv/bin/python")
		helper_inited["dap-python"] = true
	elseif dap_config.adapter == "codelldb" and not dap.adapters.codelldb then
		-- 手动注册 codelldb adapter（C/C++ 共用）
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = mason_bin .. "/codelldb",
				args = { "--port", "${port}" },
			},
		}
		local cpp_config = {
			{
				name = "Launch executable",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
		}
		dap.configurations.c = cpp_config
		dap.configurations.cpp = cpp_config
	end
end

-- ============================================================
-- DAP UI 自动开关
-- ============================================================
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- ============================================================
-- User commands
-- ============================================================
local cmd = vim.api.nvim_create_user_command

cmd("DapContinue", function()
	dap.continue()
end, { desc = "DAP: start / continue" })

cmd("DapStepOver", function()
	dap.step_over()
end, { desc = "DAP: step over" })

cmd("DapStepInto", function()
	dap.step_into()
end, { desc = "DAP: step into" })

cmd("DapStepOut", function()
	dap.step_out()
end, { desc = "DAP: step out" })

cmd("DapBreakpoint", function()
	dap.toggle_breakpoint()
end, { desc = "DAP: toggle breakpoint" })

cmd("DapBreakpointCondition", function()
	vim.ui.input({ prompt = "Breakpoint condition: " }, function(input)
		if input and input ~= "" then
			dap.set_breakpoint(input)
		end
	end)
end, { desc = "DAP: set conditional breakpoint" })

cmd("DapTerminate", function()
	dap.terminate()
end, { desc = "DAP: terminate session" })

cmd("DapREPL", function()
	dap.repl.open()
end, { desc = "DAP: open REPL" })

cmd("DapRunLast", function()
	dap.run_last()
end, { desc = "DAP: re-run last config" })

cmd("DapUIToggle", function()
	dapui.toggle()
end, { desc = "DAP: toggle UI" })

cmd("DapEval", function()
	dapui.eval()
end, { desc = "DAP: evaluate (use after visual selection)", range = true })

-- ── 可视模式求值（保留这一个 keymap，单键最实用） ────────
vim.keymap.set("v", "<leader>de", function()
	dapui.eval()
end, { desc = "DAP: evaluate selection" })

-- ── 用法 ──────────────────────────────────────────────────
-- :DapContinue / :DapBreakpoint / :DapStepOver / :DapStepInto / :DapStepOut
-- :DapBreakpointCondition         设置条件断点
-- :DapTerminate / :DapRunLast / :DapREPL / :DapUIToggle
-- :DapEval                        （配合可视选区）求值
-- <leader>de  visual 模式快速求值
--
-- ── fzf-lua 提供的 DAP 选择器 ─────────────────────────────
-- :FzfLua dap_commands           列出所有 DAP 命令
-- :FzfLua dap_breakpoints        所有断点
-- :FzfLua dap_frames             调用栈
-- :FzfLua dap_variables          变量
-- :FzfLua dap_configurations     已注册的 configuration
