-- ============================================================
-- 自定义 tree-sitter query predicates
-- 注册一些 nvim 核心未提供的、查询里好用的判断
-- ============================================================

local M = {}

--- has-descendant?: 检查捕获节点是否有指定类型的后代节点
--- 用法（在 .scm 中）：
---   ((some_node) @cap (#has-descendant? @cap function_declarator))
local function has_descendant(match, _, _, predicate)
	local capture_id = predicate[2]
	local target_type = predicate[3]

	local node = match[capture_id]
	-- nvim 0.10+ 多捕获 match 是数组；取第一个即可
	if type(node) == "table" then
		node = node[1]
	end
	if not node then
		return false
	end

	local stack = { node }
	while #stack > 0 do
		local n = table.remove(stack)
		if n:type() == target_type then
			return true
		end
		for child in n:iter_children() do
			table.insert(stack, child)
		end
	end
	return false
end

function M.setup()
	vim.treesitter.query.add_predicate("has-descendant?", has_descendant, { force = true, all = false })
end

return M
