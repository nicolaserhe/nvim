-- ============================================================
-- lazydev.nvim：写 nvim Lua 配置时的隐式增强
-- 让 lua_ls 自动认 vim.api / vim.fn / vim.uv / 已装插件的 API
-- 仅在 lua filetype 生效，其他语言完全不参与
--
-- 配合 blink.cmp 的 lazydev 源（见 lsp/completion.lua 的 per_filetype.lua）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/folke/lazydev.nvim" },
})

require("lazydev").setup({
	library = {
		-- 默认会自动加载 nvim runtime（vim.api 等）
		-- 加 vim.uv (luv) 类型补全
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- ── 用法 ──────────────────────────────────────────────────
-- 无命令、无 keymap，纯后台增强。
-- 写 lua 文件时：
--   vim.api.nvim_<Tab>      列所有 nvim_* API
--   vim.uv.<Tab>            libuv API 智能补全
--   require("trouble").<Tab> 已装插件的公共 API
--
-- :LazyDev                  查看当前 buffer 已加载的 library 路径
