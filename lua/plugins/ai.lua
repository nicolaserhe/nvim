-- =========================
-- Add Plugin
-- =========================
-- vim.pack.add {
--     { src = 'https://github.com/github/copilot.vim' },
-- }
--


-- =========================
-- Setup / Config
-- =========================
local function load_copilot()
    -- 加载插件
    vim.pack.add {
        { src = 'https://github.com/github/copilot.vim' }
    }

    -- 初始化 Copilot（必须在加载之后）
    vim.cmd(":Copilot setup")
end

-- 2. 按键触发加载，例如 Ctrl-P 启动 Copilot 补全
vim.api.nvim_create_user_command("LoadCopilot", load_copilot, {})

-- Copilot 快捷键说明：
-- <Tab>        : 接受当前建议
-- <C-J>        : 可以用 Ctrl-J 接受建议（需要自定义）
-- <C-L>        : 接受建议的一个单词
-- <C-]>        : 拒绝当前建议
-- <M-]>        : 下一个建议（Alt + 右方括号）
-- <M-[>        : 上一个建议（Alt + 左方括号）
-- <M-\>        : 显式请求建议，即使自动建议关闭
-- <M-Right>    : 接受当前建议的下一个单词
-- <M-C-Right>  : 接受当前建议的下一行


-- =========================
-- Help
-- =========================
