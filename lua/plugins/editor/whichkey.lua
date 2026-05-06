-- ============================================================
-- which-key.nvim：按下 leader 后弹按键提示
-- 因为本配置「重命令行轻 keymap」，which-key 主要服务少量必要 leader 键
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})

require("which-key").setup({
	preset = "modern", -- 现代风格：底部弹窗、分组清晰
	delay = 300, -- ms，按下 leader 后多久弹出
})

-- 注册 leader 分组（让弹窗显示分组标题而非散乱键位）
require("which-key").add({
	{ "<leader>f", group = "find (fzf-lua)" },
	{ "<leader>d", group = "debug" },
	{ "<leader>t", group = "terminal" },
})

-- ── 用法 ──────────────────────────────────────────────────
-- 按下 <leader> 等待 300ms 自动弹出可用键位
-- :WhichKey       手动触发提示
-- :checkhealth which-key
