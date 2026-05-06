-- ============================================================
-- LSP document highlight：光标停留时高亮同名符号
-- 替代 vim-illuminate：nvim 0.11+ 原生 API 已足够，少一个依赖
-- 仅对支持 documentHighlightProvider 的 LSP server 生效
-- 触发频率由 settings.lua 的 updatetime（100ms）决定
-- ============================================================
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight") then
			return
		end

		local buf = args.buf
		local group = vim.api.nvim_create_augroup("lsp_doc_highlight_" .. buf, { clear = true })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = buf,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = group,
			buffer = buf,
			callback = vim.lsp.buf.clear_references,
		})
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(args)
		pcall(vim.api.nvim_del_augroup_by_name, "lsp_doc_highlight_" .. args.buf)
		vim.lsp.buf.clear_references()
	end,
})

-- ============================================================
-- 引用高亮的视觉样式：双下划线（不染前景）
-- 默认 dracula 把 LspReference* 染成橙色前景，会盖掉 Tonsky 高亮；
-- 改成仅加双下划线（与 LSP 诊断的波浪线区分），保留原有 token 颜色。
-- ColorScheme autocmd 防止主题切换后被覆盖。
-- ============================================================
local function set_lsp_reference_underline()
	-- sp 用 base 前景白 #F8F8F2，灰蓝在深色 bg 上对比度不足
	local attrs = { underdouble = true, bg = "NONE", fg = "NONE", sp = "#F8F8F2" }
	vim.api.nvim_set_hl(0, "LspReferenceText", attrs)
	vim.api.nvim_set_hl(0, "LspReferenceRead", attrs)
	vim.api.nvim_set_hl(0, "LspReferenceWrite", attrs)
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("LspReferenceUnderline", { clear = true }),
	callback = set_lsp_reference_underline,
})

set_lsp_reference_underline()
