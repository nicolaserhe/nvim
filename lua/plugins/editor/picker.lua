-- ============================================================
-- 模糊搜索（fzf-lua）
-- 替代 telescope，性能更好（基于 fzf 二进制 + ripgrep）
-- 大 monorepo 下 live_grep / files 明显提速
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	-- nvim-web-devicons 已由 statusline 加载，此处复用
})

require("fzf-lua").setup({
	"default-title", -- 启用 default-title profile：顶部显示当前 picker 名

	winopts = {
		height = 0.85,
		width = 0.90,
		border = "rounded",
		preview = {
			layout = "flex",
			border = "rounded",
			scrollbar = "float",
		},
	},

	files = {
		prompt = "Files❯ ",
		formatter = "path.filename_first", -- 文件名优先于路径展示
	},

	grep = {
		prompt = "Rg❯ ",
		rg_glob = true, -- 支持 `pattern -- *.lua` 语法过滤
	},

	oldfiles = {
		include_current_session = true, -- 当前会话打开过的文件也算最近
	},

	keymaps = {
		fzf_opts = { ["--tiebreak"] = "index" },
	},
})

-- ── 常用命令对照 telescope ────────────────────────────────────
-- :FzfLua                       打开 picker 选择器（picker of pickers）
-- :FzfLua files                 文件搜索（替代 :Telescope find_files）
-- :FzfLua live_grep             全文 ripgrep 搜索
-- :FzfLua grep_cword            搜索光标下单词
-- :FzfLua buffers               打开的 buffer 列表
-- :FzfLua oldfiles              最近打开的文件（含 frecency 加权）
-- :FzfLua keymaps               所有 keymap（带 desc）
-- :FzfLua commands              所有 user command
-- :FzfLua command_history       命令历史
-- :FzfLua helptags              文档标签
-- :FzfLua registers             寄存器（替代 registers.nvim）
-- :FzfLua diagnostics_document  当前 buffer 诊断
-- :FzfLua diagnostics_workspace 全工作区诊断
-- :FzfLua lsp_references        LSP 引用
-- :FzfLua lsp_definitions       LSP 定义
-- :FzfLua git_files / git_status / git_commits / git_branches
-- :FzfLua dap_commands / dap_breakpoints / dap_frames
