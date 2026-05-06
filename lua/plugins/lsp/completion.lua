-- ============================================================
-- 自动补全（blink.cmp）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/saghen/blink.lib" }, -- v2 必备依赖
})

require("blink.cmp").setup({
	cmdline = { enabled = false }, -- 禁止 blink 接管命令行补全，用 neovim 原生 wildmenu
	-- ── 快捷键配置 ────────────────────────────
	keymap = {
		preset = "enter", -- 使用 Enter 确认补全

		["<C-N>"] = { "select_next", "fallback" },
		["<C-P>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<CR>"] = { "accept", "fallback" },

		["<C-Space>"] = { "show", "fallback" },

		["<C-U>"] = { "scroll_documentation_up", "fallback" },
		["<C-D>"] = { "scroll_documentation_down", "fallback" },
	},

	-- ── 外观配置 ──────────────────────────────
	appearance = {
		nerd_font_variant = "mono",
	},

	-- ── 补全行为 ──────────────────────────────
	completion = {
		accept = {
			auto_brackets = {
				enabled = true, -- 自动添加括号
			},
		},

		menu = {
			border = "rounded", -- 圆角边框
			draw = {
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", "kind" },
				},
			},
		},

		documentation = {
			auto_show = true, -- 自动显示文档
			auto_show_delay_ms = 200,
			window = {
				border = "rounded", -- 圆角边框
			},
		},
	},

	-- ── 补全源配置 ────────────────────────────
	-- minuet 仅在 DEEPSEEK_API_KEY 设置时纳入 default 源，避免 blink 触发未启动的 minuet
	sources = {
		default = (vim.env.DEEPSEEK_API_KEY or "") ~= ""
				and { "lsp", "path", "snippets", "buffer", "minuet" }
			or { "lsp", "path", "snippets", "buffer" },

		-- lua 文件前置 lazydev（vim.api/vim.uv/插件 API 智能补全）
		per_filetype = {
			lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
		},

		providers = {
			minuet = {
				name = "minuet",
				module = "minuet.blink",
				async = true,
				timeout_ms = 3000,
				score_offset = 50, -- 让 AI 候选排前
			},
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100, -- lazydev 候选最优先
			},
		},
	},

	-- ── Fuzzy matcher（v2 引入 Rust native 实现） ──────
	-- v2 不在 setup 里配置 binary 下载，而是用 require("blink.cmp").build()
	-- bootstrap.sh 末尾会调一次预热（首次 cargo 编译耗时较久）
	fuzzy = {
		implementation = "prefer_rust", -- 优先 Rust，失败回退 Lua（无警告噪音）
	},

	-- ── Snippet 配置 ──────────────────────────
	snippets = {
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
		active = function(filter)
			if filter and filter.direction then
				return vim.snippet.active(filter)
			end
			return vim.snippet.active({ direction = 1 }) or vim.snippet.active({ direction = -1 })
		end,
		jump = function(direction)
			vim.snippet.jump(direction)
		end,
	},

	-- ── 签名帮助 ──────────────────────────────
	signature = {
		enabled = true,
		window = {
			border = "rounded",
		},
	},
})

-- ── 快捷键说明 ────────────────────────────────────────────
-- <CR>         确认补全
-- <C-N>        下一项
-- <C-P>        上一项
-- <Tab>        跳转到下一个 snippet 占位符
-- <S-Tab>      跳转到上一个 snippet 占位符
-- <C-Space>    手动触发补全
-- <C-U>        向上滚动文档
-- <C-D>        向下滚动文档
