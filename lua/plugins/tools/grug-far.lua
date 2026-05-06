-- ============================================================
-- grug-far.nvim：项目级搜索替换面板
-- 一个 buffer 同时承载：搜索词 / 替换词 / glob/regex/case 选项 / 实时预览
-- 改替换词时立即看到所有匹配位置的「前 → 后」对比，确认后一次写入
-- 引擎：默认 ripgrep（fzf-lua 也用这个）
-- 懒加载：首次 :GrugFar 才加载（与 dap / sql 同模式）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/MagicDuck/grug-far.nvim" },
})

require("grug-far").setup({
	-- 默认即可。可调项：
	--   engine = "ripgrep"        默认引擎（也可 "ast-grep"，需另装 sg CLI）
	--   transient = false         关闭 buffer 时保留搜索状态
	--   keymaps = { ... }         自定义面板内 keymap
})

-- ── 用法 ──────────────────────────────────────────────────
-- :GrugFar                打开搜索替换面板
-- :GrugFarVisual          (visual 模式) 用选区作为初始搜索词
-- :GrugFarWithin          仅在当前 buffer 范围搜索
-- :GrugFarWithinVisual    visual 选区作为搜索词 + 仅当前 buffer
--
-- 面板内字段（顶部）
--   Search:        搜索 pattern（rg 默认 regex）
--   Replace:       替换 pattern（$1 $2 引用捕获组）
--   Files Filter:  rg --glob 过滤（如 "*.go" 仅 go）
--   Flags:         额外 rg 参数（如 --multiline / --fixed-strings）
--
-- 面板内默认 keymap（<localleader> 默认是 \）
--   <localleader>r        执行替换（一次性写入所有匹配文件）
--   <localleader>l        loclist 视图
--   <localleader>q        quickfix 视图
--   <localleader>w        toggle 全词匹配
--   <localleader>x        toggle 大小写敏感
--   <localleader>c        关闭面板
--
-- 与 fzf-lua live_grep 区别
--   fzf-lua: 找一个位置跳过去（一次性 picker）
--   grug-far: 看全部匹配 + 预览替换 + 批量写入（重构利器）
