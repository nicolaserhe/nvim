-- ============================================================
-- 全局快捷键（不依赖任何插件）
-- 插件专属快捷键在对应插件配置文件中定义
--
-- 设计原则：keymap 仅服务高频操作，其他功能通过 :UserCommand 暴露
-- ============================================================
local map = vim.keymap.set

-- 标签页
map("n", "]t", "<Cmd>tabnext<CR>", { noremap = true, silent = true, desc = "Next tab" })
map("n", "[t", "<Cmd>tabprevious<CR>", { noremap = true, silent = true, desc = "Prev tab" })

-- 缓冲区
map("n", "]b", "<Cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map("n", "[b", "<Cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Prev buffer" })

-- Quickfix 列表
map("n", "]q", "<Cmd>cnext<CR>", { noremap = true, silent = true, desc = "Next quickfix item" })
map("n", "[q", "<Cmd>cprevious<CR>", { noremap = true, silent = true, desc = "Prev quickfix item" })

-- 注：]a / [a 让位给 treesitter-textobjects 的参数 motion
-- 切 args 列表用 :n / :N 命令

-- ── fzf-lua 高频入口（其余功能用 :FzfLua <Tab> 自动补全或 :FzfLua 选 picker）
map("n", "<leader>ff", "<Cmd>FzfLua files<CR>", { noremap = true, silent = true, desc = "FzfLua: files" })
map("n", "<leader>fg", "<Cmd>FzfLua live_grep<CR>", { noremap = true, silent = true, desc = "FzfLua: live grep" })
map("n", "<leader>fc", "<Cmd>FzfLua commands<CR>", { noremap = true, silent = true, desc = "FzfLua: commands" })
