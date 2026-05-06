-- ============================================================
-- Neovim 配置入口
-- 加载顺序：字节码缓存 → 基础设置 → 快捷键 → 自动命令 → 缩进 → 插件
-- ============================================================

-- 启用字节码缓存（Neovim 0.9+ 内置，必须最早调用）
vim.loader.enable()

require("config.settings")
require("config.keymaps")
require("config.autocmds")
require("config.indent")
require("plugins")
