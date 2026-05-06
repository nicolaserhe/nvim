-- ============================================================
-- 状态栏 & Tabline（lualine）
-- ============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

-- 右侧显示当前 buffer 的 LSP 客户端名称
local function lsp_clients()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end
	local names = vim.tbl_map(function(c)
		return c.name
	end, clients)
	return " " .. table.concat(names, ", ") .. string.rep(" ", 1)
end

-- 右侧显示「行/总行 列」
local function cursor_pos()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local total = vim.api.nvim_buf_line_count(0)
	return string.format(":%d/%d :%d ", row, total, col + 1)
end

local _distro_icon = nil
local function get_fileformat_icon()
	if not _distro_icon then
		local f = io.open("/etc/os-release", "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content:match("Arch") then
				_distro_icon = "󰣇 "
			elseif content:match("Ubuntu") then
				_distro_icon = " "
			elseif content:match("Debian") then
				_distro_icon = " "
			elseif content:match("Manjaro") then
				_distro_icon = " "
			else
				_distro_icon = "󰌽 "
			end
		else
			_distro_icon = "󰌽 "
		end
	end
	return _distro_icon
end

require("lualine").setup({
	options = { globalstatus = true },

	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = {
			{ lsp_clients, separator = "" },
			"filetype",
		},
		lualine_y = {
			{ "encoding", separator = "" },
			{ get_fileformat_icon, separator = "" },
			{ "searchcount", separator = "" },
			{ "selectioncount", separator = "" },
		},
		lualine_z = {
			{ "progress", separator = "" },
			{ cursor_pos, separator = "", padding = 0 },
		},
	},

	tabline = {
		lualine_a = { "buffers" },
		lualine_z = { "tabs" },
	},

	extensions = { "nvim-tree", "quickfix" },
})
