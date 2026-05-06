-- ============================================================
-- LSP 服务器注册与配置
-- 所有配置在 lua/config/languages.lua 中管理
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

local lsp = vim.lsp
local languages = require("config.languages")

-- 启用所有 LSP 服务器
for _, srv in ipairs(languages.get_lsp_servers()) do
	lsp.enable(srv)
end

-- 应用服务器特定配置
for _, srv in ipairs(languages.get_lsp_servers()) do
	local config = languages.get_lsp_config(srv)
	if config then
		lsp.config(srv, config)
	end
end
