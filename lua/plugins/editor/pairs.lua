-- ============================================================
-- 编辑增强：括号补全、surround、注释
-- 寄存器预览改用 :FzfLua registers
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/kylechui/nvim-surround" },
	{ src = "https://github.com/numToStr/Comment.nvim" },
})

require("nvim-autopairs").setup({
	map_c_h = true, -- 映射 <C-h> 用于成对删除
})
require("nvim-surround").setup({})

-- ── 快捷键说明 ────────────────────────────────────────────
-- nvim-surround（普通模式）
--   ys{motion}{char}   添加包裹，例：ysiw" 给单词加双引号
--   cs{old}{new}       替换包裹，例：cs"'  双引号换单引号
--   ds{char}           删除包裹，例：ds"   删除双引号
--
-- Comment.nvim
--   gcc  行注释切换
--   gbc  块注释切换
--   gc{motion}  注释 motion 范围
--
-- 寄存器预览
--   :FzfLua registers  （替代旧 registers.nvim 的弹窗）
