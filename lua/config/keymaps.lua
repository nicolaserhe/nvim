-- =======================================================
-- 快捷键模块
-- =======================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true } -- 非递归、静默执行


-- ------------------------
-- 标签页切换
-- ------------------------
map('n', ']t', ':tabnext<CR>', opts)     -- 下一个标签页
map('n', '[t', ':tabprevious<CR>', opts) -- 上一个标签页

-- ------------------------
-- buffer 切换
-- ------------------------
map('n', ']b', ':bnext<CR>', opts)     -- 下一个 buffer
map('n', '[b', ':bprevious<CR>', opts) -- 上一个 buffer

-- ------------------------
-- quickfix 列表跳转
-- ------------------------
map('n', ']q', ':cnext<CR>', opts)     -- 下一个 quickfix
map('n', '[q', ':cprevious<CR>', opts) -- 上一个 quickfix

-- ------------------------
-- 普通文件跳转
-- ------------------------
map('n', ']a', ':next<CR>', opts)     -- 下一个文件
map('n', '[a', ':previous<CR>', opts) -- 上一个文件
