-- ============================================================
-- 测试运行框架（neotest）
-- adapter 由 languages.lua 的 test 字段驱动；新增语言只需在 LANGUAGES
-- 里加 test = { adapter, opts? }，本文件无需改动
--
-- 启动时立即加载（开发流高频，立即可用体验更好）
-- ============================================================
local languages = require("config.languages")

-- ── 聚合所有 vim.pack 依赖（neotest 框架 + 各 adapter） ──
-- nvim-nio / plenary 已被 dap / minuet 声明（vim.pack.add 幂等，
-- 但这里仍显式声明，保证 test.lua 自洽：删 dap 也不影响 test）
local pack_specs = {
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
}
for _, cfg in pairs(languages.get_test_configs()) do
	local src = cfg.src or ("https://github.com/nvim-neotest/" .. cfg.adapter)
	table.insert(pack_specs, { src = src })
end
vim.pack.add(pack_specs)

-- ── 实例化各 adapter ─────────────────────────────────────
local adapters = {}
for lang, cfg in pairs(languages.get_test_configs()) do
	local ok, mod = pcall(require, cfg.adapter)
	if ok then
		table.insert(adapters, mod(cfg.opts or {}))
	else
		vim.notify(
			string.format("neotest: failed to load adapter %s for %s: %s", cfg.adapter, lang, mod),
			vim.log.levels.WARN
		)
	end
end

require("neotest").setup({
	adapters = adapters,
	-- 默认即可。可调项：
	--   discovery.enabled = false  关闭后台 test 自动发现（大项目可降负载）
	--   summary.open = "topleft vsplit | vertical resize 50"  自定义 summary 窗口
	--   output.open_on_run = true  跑完自动打开 output 浮窗
})

-- ── 用法（命令均带 Tab 补全） ────────────────────────────
-- 跑测试
--   :Neotest run                  跑光标处测试
--   :Neotest run file             跑当前文件
--   :Neotest run last             重跑上次
--   :Neotest run suite            跑全套（多 adapter 时按工作区）
--   :Neotest run dap              跑光标处测试 + 进入 dap 调试
--   :Neotest stop                 停止当前测试
--
-- 查看
--   :Neotest summary toggle       侧边栏（树形测试结构 + pass/fail 状态）
--   :Neotest output               当前测试输出（浮窗）
--   :Neotest output-panel toggle  持久 output 面板
--
-- 跳转
--   :Neotest jump next            下一个测试
--   :Neotest jump prev            上一个测试
--
-- summary 面板内默认 keymap：
--   r       跑测试
--   d       调试（启动 dap）
--   o       看 output
--   s       停止
--   m       标记 / 跑标记的所有测试
--   <CR>    跳到测试源码
--   ?       帮助
