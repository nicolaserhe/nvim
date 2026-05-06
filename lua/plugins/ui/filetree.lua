-- ============================================================
-- 文件树 / 目录浏览（oil.nvim）
-- 现代范式：buffer-as-directory，用文本编辑的方式管理文件
-- 重命名 / 移动 / 创建 / 删除 = 编辑这个 buffer 的文本
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/stevearc/oil.nvim" },
})

require("oil").setup({
	default_file_explorer = true, -- 取代 netrw

	-- 仅展示设置
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name)
			return name == ".." or name == ".git"
		end,
	},

	delete_to_trash = true, -- 删除走系统回收站

	-- 跳过简单编辑确认（如重命名一个文件不弹窗）
	skip_confirm_for_simple_edits = true,

	-- buffer 内的快捷键（仅在 oil buffer 中生效）
	keymaps = {
		["q"] = { "actions.close", mode = "n" },
		["g?"] = { "actions.show_help", mode = "n" },
		["<CR>"] = "actions.select",
		["<C-s>"] = { "actions.select", opts = { vertical = true } },
		["<C-h>"] = { "actions.select", opts = { horizontal = true } },
		["<C-t>"] = { "actions.select", opts = { tab = true } },
		["<C-p>"] = "actions.preview",
		["<C-r>"] = "actions.refresh",
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["g."] = { "actions.toggle_hidden", mode = "n" },
	},

	use_default_keymaps = false,
})

-- ── 用法 ──────────────────────────────────────────────────
-- :Oil          在当前文件所在目录打开 oil buffer
-- :Oil <path>   在指定路径打开
-- -             （在 oil buffer 内）跳到上级目录
-- _             （在 oil buffer 内）跳到 cwd
-- q             关闭 oil buffer
-- <CR>          选中（打开文件 / 进入目录）
-- <C-s>/<C-h>   垂直/水平分割打开
-- <C-p>         预览文件
-- g?            buffer 内快捷键帮助
-- g.            切换隐藏文件显示
--
-- 编辑示例：
--   修改文件名 → 直接改 buffer 里的文件名行 → :w 落盘
--   删除文件   → 删除对应行 → :w 落盘
--   创建文件   → 加一行写新文件名 → :w 落盘
--   移动文件   → 行剪切粘贴到另一个 oil buffer（同进程下不同目录） → :w 落盘
