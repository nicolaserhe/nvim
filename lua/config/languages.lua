-- ============================================================
-- 语言配置中心 - 所有语言相关的配置集中在此
-- 新增/修改语言只需编辑这一个文件
-- ============================================================

---@class DapConfig
---@field adapter string DAP adapter 名（dap.adapters.<adapter> 注册时使用）
---@field mason string|nil Mason 包名（用于 mason-tool-installer 自动安装二进制）
---@field helper string|nil 辅助插件 setup 名（如 "dap-go" / "dap-python"）；为 nil 时由 dap.lua 手动注册 adapter

---@class TestConfig
---@field adapter string neotest adapter 模块名（require 名 = vim.pack 默认 URL 的最后一段）
---@field src string|nil 非默认 GitHub org 时填完整 URL（默认 https://github.com/nvim-neotest/<adapter>）
---@field opts table|nil adapter 实例化时的选项（传给 require(adapter)(opts)）

---@class LanguageConfig
---@field lsp string|nil LSP 服务器名称
---@field treesitter boolean|nil 是否启用 Treesitter
---@field treesitter_parser string|nil Treesitter parser 名称（当 parser 名与 filetype 不同时使用）
---@field treesitter_extra_parsers string[]|nil 额外需要的 parser（如 markdown 配套的 markdown_inline）
---@field indent_mode string|nil 缩进模式: "cindent" | "smartindent" | "autoindent" | "treesitter"
---@field formatters string[]|nil 格式化工具列表
---@field format_on_save boolean|nil 保存时自动格式化（默认 false，需手动调用）
---@field linters string[]|nil 静态检查工具列表
---@field mason_extras string[]|nil 额外需要安装的 Mason 工具
---@field dap DapConfig|nil 调试器配置
---@field test TestConfig|nil 测试运行配置（neotest adapter）

-- ============================================================
-- LSP 服务器级配置（按 server 名键入，避免共用 server 时配置重复）
-- 例如 c 与 cpp 都用 clangd，配置只需写一次
-- ============================================================
---@type table<string, table>
local LSP_CONFIGS = {
	clangd = {
		on_attach = function(client)
			-- 禁用 semantic tokens，避免与 Treesitter 高亮冲突
			client.server_capabilities.semanticTokensProvider = nil
		end,
	},

	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
			},
		},
	},
}

-- ============================================================
-- lspconfig server 名 → mason 包名 翻译表
-- 仅列出两者不一致的 server；一致的（gopls/clangd/pyright/...）无需登记
-- 取代了之前 mason-lspconfig 提供的同名功能
-- ============================================================
---@type table<string, string>
local LSP_TO_MASON = {
	bashls = "bash-language-server",
	lua_ls = "lua-language-server",
	yamlls = "yaml-language-server",
	jsonls = "json-lsp",
}

---@type table<string, LanguageConfig>
local LANGUAGES = {
	go = {
		lsp = "gopls",
		treesitter = true,
		indent_mode = "cindent",
		formatters = { "gofumpt", "goimports" },
		format_on_save = true, -- 保存时自动格式化
		-- linters          = { "staticcheck" },
		dap = {
			adapter = "delve",
			mason = "delve",
			helper = "dap-go",
		},
		test = {
			adapter = "neotest-go",
		},
	},

	c = {
		lsp = "clangd",
		treesitter = true,
		indent_mode = "cindent",
		format_on_save = false, -- 不自动格式化，手动调用
		dap = {
			adapter = "codelldb",
			mason = "codelldb",
		},
	},

	cpp = {
		lsp = "clangd",
		treesitter = true,
		indent_mode = "cindent",
		format_on_save = false,
		dap = {
			adapter = "codelldb",
			mason = "codelldb",
		},
	},

	lua = {
		lsp = "lua_ls",
		treesitter = true,
		indent_mode = "smartindent",
		formatters = { "stylua" },
		format_on_save = true,
	},

	python = {
		lsp = "pyright",
		treesitter = true,
		indent_mode = "autoindent",
		formatters = { "black" },
		format_on_save = true,
		dap = {
			adapter = "debugpy",
			mason = "debugpy",
			helper = "dap-python",
		},
	},

	sh = {
		lsp = "bashls",
		treesitter = true,
		treesitter_parser = "bash",
		indent_mode = "smartindent",
		formatters = { "shfmt" },
		format_on_save = true,
	},

	yaml = {
		lsp = "yamlls",
		treesitter = true,
		indent_mode = "autoindent",
		format_on_save = true,
	},

	json = {
		lsp = "jsonls",
		treesitter = true,
		indent_mode = "smartindent",
		format_on_save = true,
	},

	proto = {
		lsp = "protols",
		treesitter = false,
		indent_mode = "cindent",
		formatters = { "buf" },
		format_on_save = true,
	},

	markdown = {
		lsp = "marksman",
		treesitter = true,
		treesitter_extra_parsers = { "markdown_inline" }, -- render-markdown 内联渲染依赖
		indent_mode = "autoindent",
		format_on_save = true,
	},

	sql = {
		lsp = "sqls",
		treesitter = false,
		indent_mode = "smartindent",
		format_on_save = false,
	},
}

-- ============================================================
-- 导出接口 - 供其他模块调用
-- ============================================================

local M = {}

--- 获取所有 LSP 服务器名称（去重）
---@return string[]
function M.get_lsp_servers()
	local servers = {}
	local seen = {}
	for _, config in pairs(LANGUAGES) do
		if config.lsp and not seen[config.lsp] then
			table.insert(servers, config.lsp)
			seen[config.lsp] = true
		end
	end
	return servers
end

--- 获取服务器的额外配置（按 server 名查表）
---@param server_name string
---@return table|nil
function M.get_lsp_config(server_name)
	return LSP_CONFIGS[server_name]
end

--- 获取所有 Treesitter parser 名称（含 treesitter_extra_parsers，去重）
--- 主 parser 优先使用 treesitter_parser 字段，不存在则回退到 lang（即键名）
---@return string[]
function M.get_treesitter_parsers()
	local parsers = {}
	local seen = {}
	for lang, config in pairs(LANGUAGES) do
		if config.treesitter then
			local main = config.treesitter_parser or lang
			if not seen[main] then
				table.insert(parsers, main)
				seen[main] = true
			end
			if config.treesitter_extra_parsers then
				for _, p in ipairs(config.treesitter_extra_parsers) do
					if not seen[p] then
						table.insert(parsers, p)
						seen[p] = true
					end
				end
			end
		end
	end
	return parsers
end

--- 按缩进模式分组语言
---@return table<string, string[]>  { cindent = {...}, smartindent = {...}, ... }
function M.get_langs_by_indent_mode()
	local grouped = {
		cindent = {},
		smartindent = {},
		autoindent = {},
		treesitter = {},
	}

	for lang, config in pairs(LANGUAGES) do
		local mode = config.indent_mode or "autoindent" -- 默认使用 autoindent
		if grouped[mode] then
			table.insert(grouped[mode], lang)
		end
	end

	return grouped
end

--- 获取所有 formatters 配置（按文件类型分组）
---@return table<string, string[]>
function M.get_formatters_by_ft()
	local formatters = {}
	for lang, config in pairs(LANGUAGES) do
		if config.formatters then
			formatters[lang] = config.formatters
		end
	end
	return formatters
end

--- 获取所有 linters 配置（按文件类型分组）
---@return table<string, string[]>
function M.get_linters_by_ft()
	local linters = {}
	for lang, config in pairs(LANGUAGES) do
		if config.linters then
			linters[lang] = config.linters
		end
	end
	return linters
end

--- 获取所有需要 DAP 调试支持的语言配置（按 filetype 分组）
---@return table<string, DapConfig>
function M.get_dap_configs()
	local configs = {}
	for lang, config in pairs(LANGUAGES) do
		if config.dap then
			configs[lang] = config.dap
		end
	end
	return configs
end

--- 获取所有需要 neotest 测试支持的语言配置（按 filetype 分组）
---@return table<string, TestConfig>
function M.get_test_configs()
	local configs = {}
	for lang, config in pairs(LANGUAGES) do
		if config.test then
			configs[lang] = config.test
		end
	end
	return configs
end

--- 获取需要保存时自动格式化的文件类型列表
---@return string[]
function M.get_format_on_save_filetypes()
	local filetypes = {}
	for lang, config in pairs(LANGUAGES) do
		if config.format_on_save == true then
			table.insert(filetypes, lang)
		end
	end
	return filetypes
end

--- 检查指定文件类型是否需要保存时自动格式化
---@param filetype string
---@return boolean
function M.should_format_on_save(filetype)
	local config = LANGUAGES[filetype]
	return config and config.format_on_save == true
end

--- 获取所有需要通过 Mason 安装的工具
---@return string[]
function M.get_mason_tools()
	local tools = {}
	local seen = {}

	-- LSP servers（翻译成 mason 包名后入表）
	for _, server in ipairs(M.get_lsp_servers()) do
		local pkg = LSP_TO_MASON[server] or server
		if not seen[pkg] then
			table.insert(tools, pkg)
			seen[pkg] = true
		end
	end

	-- Formatters
	for _, formatters in pairs(M.get_formatters_by_ft()) do
		for _, formatter in ipairs(formatters) do
			if not seen[formatter] then
				table.insert(tools, formatter)
				seen[formatter] = true
			end
		end
	end

	-- Linters
	for _, linters in pairs(M.get_linters_by_ft()) do
		for _, linter in ipairs(linters) do
			if not seen[linter] then
				table.insert(tools, linter)
				seen[linter] = true
			end
		end
	end

	-- DAP adapters（delve / debugpy / codelldb 等）
	for _, dap_config in pairs(M.get_dap_configs()) do
		if dap_config.mason and not seen[dap_config.mason] then
			table.insert(tools, dap_config.mason)
			seen[dap_config.mason] = true
		end
	end

	-- 额外工具
	for _, config in pairs(LANGUAGES) do
		if config.mason_extras then
			for _, tool in ipairs(config.mason_extras) do
				if not seen[tool] then
					table.insert(tools, tool)
					seen[tool] = true
				end
			end
		end
	end

	return tools
end

--- 打印当前语言配置统计（调试用）
function M.show_stats()
	local dap_count = 0
	for _ in pairs(M.get_dap_configs()) do
		dap_count = dap_count + 1
	end
	local test_count = 0
	for _ in pairs(M.get_test_configs()) do
		test_count = test_count + 1
	end

	print("=== Language Configuration Stats ===")
	print("LSP Servers:      " .. #M.get_lsp_servers())
	print("Treesitter:       " .. #M.get_treesitter_parsers())
	print("Mason Tools:      " .. #M.get_mason_tools())
	print("Auto Format:      " .. #M.get_format_on_save_filetypes())
	print("DAP Configs:      " .. dap_count)
	print("Test Configs:     " .. test_count)

	print("\n=== Indent Modes ===")
	local indent_groups = M.get_langs_by_indent_mode()
	for mode, langs in pairs(indent_groups) do
		if #langs > 0 then
			print(mode .. ": " .. table.concat(langs, ", "))
		end
	end

	print("\n=== Format on Save ===")
	local auto_fmt = M.get_format_on_save_filetypes()
	if #auto_fmt > 0 then
		print("Enabled: " .. table.concat(auto_fmt, ", "))
	else
		print("Enabled: (none)")
	end
end

return M
