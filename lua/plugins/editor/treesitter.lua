-- ============================================================
-- 语法高亮（Treesitter 安装 + 启动 + 上下文显示）
-- 缩进配置在 lua/config/indent.lua
-- 自定义高亮规则在 lua/config/highlights.lua（用户填入）
--
-- 使用 nvim-treesitter main 分支（为 nvim 0.10+ 重写的现代版）。
-- parser 由 nvim-treesitter 调用本地 tree-sitter CLI 编译生成 .so。
-- 系统需预装 tree-sitter CLI（pacman -S tree-sitter-cli / cargo install / npm -g）。
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})

-- 注册自定义 query predicate（如 #has-descendant?）
require("util.ts_predicates").setup()

local languages = require("config.languages")

-- 安装 parsers（main 分支用 .install 而非 .setup）
-- 异步执行，首次启动会下载未装的 parser .so
require("nvim-treesitter").install(languages.get_treesitter_parsers())

-- 进入 buffer 时尝试启动 TS 高亮（无对应 parser 时静默跳过）
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- 主题加载/切换后重新应用用户自定义高亮规则
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		require("config.highlights").apply()
	end,
})

-- 首次加载时也应用一次（init 期间 ColorScheme 可能已经触发过）
require("config.highlights").apply()
