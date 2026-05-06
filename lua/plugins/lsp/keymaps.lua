-- ============================================================
-- LSP 快捷键（仅在 LSP 附加到 buffer 后生效）
-- 大部分动作走 :Lsp* user command；keymap 只保留高频跳转
-- ============================================================
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buf = args.buf
		local lsp = vim.lsp
		local function bmap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buf, noremap = true, silent = true, desc = desc })
		end

		-- 高频跳转
		bmap("n", "gd", lsp.buf.definition, "LSP: goto definition")
		bmap("n", "gD", lsp.buf.declaration, "LSP: goto declaration")
		bmap("n", "gt", lsp.buf.type_definition, "LSP: goto type definition")

		-- 文档 & 签名
		bmap("n", "K", lsp.buf.hover, "LSP: hover doc")
		bmap("i", "<C-S>", lsp.buf.signature_help, "LSP: signature help")

		-- Buffer 级 user command（避免污染全局命令空间）
		local function bcmd(name, fn, opts)
			vim.api.nvim_buf_create_user_command(buf, name, fn, opts or {})
		end

		bcmd("LspReferences", lsp.buf.references, { desc = "LSP: list references" })
		bcmd("LspIncomingCalls", lsp.buf.incoming_calls, { desc = "LSP: incoming calls" })
		bcmd("LspOutgoingCalls", lsp.buf.outgoing_calls, { desc = "LSP: outgoing calls" })
		bcmd("LspDocumentSymbols", lsp.buf.document_symbol, { desc = "LSP: document symbols" })
		bcmd("LspImplementation", lsp.buf.implementation, { desc = "LSP: list implementations" })
		bcmd("LspRename", function()
			lsp.buf.rename()
		end, { nargs = 0, desc = "LSP: rename symbol" })
	end,
})

-- ── 快捷键说明 ────────────────────────────────────────────
-- gd               跳转到定义
-- gD               跳转到声明
-- gt               跳转到类型定义
-- K                悬停文档
-- <C-S>            函数签名（插入模式）
-- gra              代码操作（Neovim 内置）
-- :LspRename           重命名符号
-- :LspReferences       查找引用（buffer 级）
-- :LspIncomingCalls    被调用位置
-- :LspOutgoingCalls    调用了哪些函数
-- :LspDocumentSymbols  当前文件符号列表
-- :LspImplementation   接口实现列表
--
-- fzf-lua 等价（更现代）：
--   :FzfLua lsp_references / lsp_definitions / lsp_typedefs
--   :FzfLua lsp_document_symbols / lsp_workspace_symbols
--   :FzfLua lsp_incoming_calls / lsp_outgoing_calls
--   :FzfLua lsp_implementations
