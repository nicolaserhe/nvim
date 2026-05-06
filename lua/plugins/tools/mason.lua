-- ============================================================
-- 工具链安装器（mason + mason-tool-installer）
-- 统一管理 LSP 服务器、formatter、linter 的安装
-- LSP 启用走 0.11+ 的原生 vim.lsp.enable（见 lsp/servers.lua），
-- 故无需 mason-lspconfig 中转
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

require("mason").setup({})

-- 从语言配置一次性聚合 LSP 服务器、formatter、linter，统一交给 mason-tool-installer
local languages = require("config.languages")

require("mason-tool-installer").setup({
	ensure_installed = languages.get_mason_tools(),
	auto_update = false,
	run_on_start = true,
})

-- ── 常用命令 ─────────────────────────────────────────────
-- :Mason               打开 Mason UI
-- :MasonInstall <pkg>  安装指定包
-- :MasonUninstall <pkg> 卸载指定包
-- :MasonUpdate         更新全部已安装的包
-- :LspInstall <server> 安装 LSP 服务器
--
-- ── 工作流程 ─────────────────────────────────────────────
-- 1. 启动时自动检查并安装缺失工具
-- 2. 新增语言只需编辑 lua/config/languages.lua
-- 3. 重启 Neovim 后自动安装新增的工具
--
-- ── 调试命令 ─────────────────────────────────────────────
-- :lua require("config.languages").show_stats()  查看配置统计
