-- ============================================================
-- 浮动终端（toggleterm）- 支持多终端
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
})

require("toggleterm").setup({
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	open_mapping = [[<C-\>]], -- Ctrl+\ 切换 1 号终端
	hide_numbers = true,
	shade_terminals = false,
	start_in_insert = true,
	insert_mappings = true,
	terminal_mappings = true,
	persist_size = true,
	persist_mode = true,
	direction = "float", -- 默认使用浮动终端
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved", -- 圆角边框
		width = math.floor(vim.o.columns * 0.85), -- 宽度 85%
		height = math.floor(vim.o.lines * 0.85), -- 高度 85%
		winblend = 0, -- 不透明
		zindex = 50, -- 置顶显示
	},
})

-- ── 终端模式快捷键 ────────────────────────────────────────
function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts) -- Esc 退出终端模式
end

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*toggleterm#*",
	callback = function()
		_G.set_terminal_keymaps()
	end,
})

-- ── 多终端快捷键 ──────────────────────────────────────────
local map = vim.keymap.set

-- 快速切换到指定编号的终端（1-5号），普通 + 终端模式都生效
for i = 1, 5 do
	local lhs = "<leader>" .. i
	local rhs = "<Cmd>" .. i .. "ToggleTerm<CR>"
	local desc = "Toggle terminal #" .. i
	map("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
	map("t", lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- 终端选择器（toggleterm 内置）
map("n", "<leader>tt", "<Cmd>TermSelect<CR>", { noremap = true, silent = true, desc = "Pick a terminal" })

-- ── 快捷键说明 ────────────────────────────────────────────
-- <C-\>           切换 1 号终端（默认终端）
-- <leader>1-5     切换到对应编号的终端（1-5），普通+终端模式都可用
-- <leader>tt      终端选择器
-- <Esc>           退出终端模式（进入普通模式）
--
-- ── 使用场景示例 ─────────────────────────────────────────
-- 1号终端：运行 Go 程序
-- 2号终端：查看 Git 日志
-- 3号终端：运行数据库查询
-- 4号终端：监控日志文件
-- 5号终端：其他临时命令
--
-- ── 常用命令 ─────────────────────────────────────────────
-- :ToggleTerm                      切换默认终端（1号）
-- :1ToggleTerm                     切换 1 号终端
-- :2ToggleTerm                     切换 2 号终端
-- :ToggleTermToggleAll             切换所有终端的显示/隐藏
