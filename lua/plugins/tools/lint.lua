-- ============================================================
-- 静态分析（nvim-lint）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-lint" },
})

-- 从语言配置加载 linters
local languages = require("config.languages")
local lint = require("lint")

lint.linters_by_ft = languages.get_linters_by_ft()

-- 保存后触发 lint
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		lint.try_lint()
	end,
})

-- ── 说明 ─────────────────────────────────────────────────
-- lint 结果以诊断形式显示，可通过 :Diagnostics 系列命令查看
-- 新增语言只需在 lua/config/languages.lua 中添加配置
