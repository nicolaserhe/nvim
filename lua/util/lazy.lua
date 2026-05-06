-- ============================================================
-- 简易懒加载工具：把"vim.pack.add + require setup"延迟到首次使用
-- 适合命令触发或事件触发的重插件，避免启动时一次性吃下所有
-- ============================================================

local M = {}

--- 用 stub user command 占位，首次调用时加载真模块再转发命令
---@param module string 模块路径，如 "plugins.tools.dap"
---@param commands string[] 该模块负责注册的所有 user command 名
function M.on_cmd(module, commands)
	for _, cmd in ipairs(commands) do
		vim.api.nvim_create_user_command(cmd, function(args)
			-- 删除所有 stub，避免重入
			for _, c in ipairs(commands) do
				pcall(vim.api.nvim_del_user_command, c)
			end
			-- 加载真模块（其内部会注册真命令）
			require(module)
			-- 重放原始调用
			local cmd_str = cmd
			if args.bang then
				cmd_str = cmd_str .. "!"
			end
			if args.args and args.args ~= "" then
				cmd_str = cmd_str .. " " .. args.args
			end
			if args.range > 0 then
				cmd_str = args.line1 .. "," .. args.line2 .. cmd_str
			end
			vim.cmd(cmd_str)
		end, { nargs = "*", range = true, bang = true, desc = "[lazy] " .. module })
	end
end

--- 用 stub keymap 占位，首次按下时加载真模块再回放按键
---@param module string
---@param keys string[] 触发按键列表（仅 normal 模式 stub）
function M.on_keys(module, keys)
	for _, key in ipairs(keys) do
		vim.keymap.set("n", key, function()
			for _, k in ipairs(keys) do
				pcall(vim.keymap.del, "n", k)
			end
			require(module)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "m", false)
		end, { desc = "[lazy] " .. module })
	end
end

--- 一次性 autocmd 触发加载
---@param module string
---@param events string|string[] 触发事件
function M.on_event(module, events)
	local group = vim.api.nvim_create_augroup("LazyLoad_" .. module:gsub("%.", "_"), { clear = true })
	vim.api.nvim_create_autocmd(events, {
		group = group,
		once = true,
		callback = function()
			require(module)
		end,
	})
end

return M
