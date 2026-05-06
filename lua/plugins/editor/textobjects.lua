-- ============================================================
-- Treesitter 文本对象（nvim-treesitter-textobjects, main 分支）
-- 基于 AST 的文本对象与 motion，扩展 vim 原生 textobject 能力
-- 不破坏 vim 默认行为，仅新增（af/if 等）+ 增强（]m/[m 扩到全语言）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true, -- 光标在对象前也能跳过去选中
	},
	move = {
		set_jumps = true, -- 跳转写 jumplist，<C-o>/<C-i> 可回退
	},
})

-- ── select / move 函数包装 ───────────────────────────────
local sel = require("nvim-treesitter-textobjects.select")
local mov = require("nvim-treesitter-textobjects.move")

local function s(query)
	return function()
		sel.select_textobject(query, "textobjects")
	end
end
local function ns(query)
	return function()
		mov.goto_next_start(query, "textobjects")
	end
end
local function ps(query)
	return function()
		mov.goto_previous_start(query, "textobjects")
	end
end
local function ne(query)
	return function()
		mov.goto_next_end(query, "textobjects")
	end
end
local function pe(query)
	return function()
		mov.goto_previous_end(query, "textobjects")
	end
end

local map = vim.keymap.set
local SEL = { "x", "o" } -- visual + operator-pending
local NAV = { "n", "x", "o" } -- normal + visual + operator-pending

-- ── select：文本对象选择 ─────────────────────────────────
map(SEL, "af", s("@function.outer"), { desc = "TS: a function" })
map(SEL, "if", s("@function.inner"), { desc = "TS: in function" })
map(SEL, "ac", s("@class.outer"), { desc = "TS: a class" })
map(SEL, "ic", s("@class.inner"), { desc = "TS: in class" })
map(SEL, "aa", s("@parameter.outer"), { desc = "TS: a parameter" })
map(SEL, "ia", s("@parameter.inner"), { desc = "TS: in parameter" })
map(SEL, "al", s("@loop.outer"), { desc = "TS: a loop" })
map(SEL, "il", s("@loop.inner"), { desc = "TS: in loop" })

-- ── move：跳转 ───────────────────────────────────────────
map(NAV, "]m", ns("@function.outer"), { desc = "TS: next func start" })
map(NAV, "[m", ps("@function.outer"), { desc = "TS: prev func start" })
map(NAV, "]M", ne("@function.outer"), { desc = "TS: next func end" })
map(NAV, "[M", pe("@function.outer"), { desc = "TS: prev func end" })
map(NAV, "]a", ns("@parameter.outer"), { desc = "TS: next parameter" })
map(NAV, "[a", ps("@parameter.outer"), { desc = "TS: prev parameter" })

-- ── 用法 ──────────────────────────────────────────────────
-- 文本对象（配合 d/y/c/v 操作符）
--   daf   删除整个 function
--   yaf   yank function
--   cif   清空函数体进入 insert
--   vif:s/x/y/g<CR>   仅函数内替换 x→y
--   vac   选中整个 class
--   >al   缩进整个 loop
--   vaa   选中一个参数（含分隔逗号）
--
-- 跳转 motion
--   ]m / [m   下/上一个 function 开头
--   ]M / [M   下/上一个 function 结尾
--   ]a / [a   下/上一个参数
--
-- 跨语言：基于 treesitter AST，所有装了 parser 的语言都生效
-- （go / python / lua / c / cpp / sh / yaml / json / markdown 等）
