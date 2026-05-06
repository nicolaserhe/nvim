-- ============================================================
-- 启动页（mini.starter）
-- 主菜单为项目列表（动态从 persistence sessions 解码 cwd，按 mtime 倒序）
-- 选中项目 → cd + 自动加载该 session
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.starter" },
})

local starter = require("mini.starter")

-- ── 项目列表生成器 ───────────────────────────────────────
-- persistence.nvim 编码：cwd 的 "/" 替换为 "%"，加 ".vim" 后缀
--   /home/gcy/.config/nvim → %home%gcy%.config%nvim.vim
-- 解码逆操作即可
local function project_items()
	local sessions_dir = vim.fn.stdpath("state") .. "/sessions"
	if vim.fn.isdirectory(sessions_dir) == 0 then
		return {}
	end

	-- 收集 session 文件 + mtime
	local entries = {}
	for _, file in ipairs(vim.fn.readdir(sessions_dir)) do
		local stat = vim.uv.fs_stat(sessions_dir .. "/" .. file)
		if stat then
			table.insert(entries, { file = file, mtime = stat.mtime.sec })
		end
	end
	-- 最近用过的 session 排前
	table.sort(entries, function(a, b)
		return a.mtime > b.mtime
	end)

	local items = {}
	for _, e in ipairs(entries) do
		local cwd = e.file:gsub("%.vim$", ""):gsub("%%", "/")
		if vim.fn.isdirectory(cwd) == 1 then
			local display = vim.fn.fnamemodify(cwd, ":~") -- 显示时把 $HOME 缩为 ~
			table.insert(items, {
				name = display,
				action = function()
					vim.cmd("cd " .. vim.fn.fnameescape(cwd))
					require("persistence").load()
				end,
				section = "Projects",
			})
		end
	end

	return items
end

starter.setup({
	header = table.concat({
		"┓┏┓ ┳┳┓",
		"┃┃ ┏┳┓",
		"┛  ┗┛┗ ",
		"",
		"  Neovim",
	}, "\n"),

	footer = "",

	items = {
		project_items, -- 动态生成 Projects 节
		{ name = "Find files", action = "FzfLua files", section = "Other" },
		{ name = "Recent files", action = "FzfLua oldfiles", section = "Other" },
		{ name = "Live grep", action = "FzfLua live_grep", section = "Other" },
		{ name = "Help tags", action = "FzfLua helptags", section = "Other" },
		{ name = "Choose session", action = "PersistenceSelect", section = "Other" },
		{ name = "Quit", action = "qall", section = "Other" },
	},

	content_hooks = {
		starter.gen_hook.adding_bullet(),
		starter.gen_hook.aligning("center", "center"),
	},
})

-- ── 常用命令 ─────────────────────────────────────────────
-- :Starter         打开启动页（空 nvim 启动时自动显示）
--
-- 启动页两节：
--   Projects  动态扫 ~/.local/share/nvim/state/sessions/，每个 session = 一个曾打开的项目
--             选中 → cd + PersistenceLoad
--   Other     备用入口（Find files / Recent / Live grep / Help / Choose session / Quit）
