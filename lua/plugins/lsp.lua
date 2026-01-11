-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    { src = 'https://github.com/neovim/nvim-lspconfig' }, -- LSP 配置
    { src = 'https://github.com/hrsh7th/nvim-cmp' },      -- 补全框架
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },  -- LSP 补全源
}


-- =========================
-- Setup / Config
-- =========================
-- --- nvim-lspconfig ---
-- 启用 LSP
vim.lsp.enable('gopls')   -- 启用 Go 语言 LSP
vim.lsp.enable('clangd')  -- 启用 C/CPP LSP
vim.lsp.enable('lua_ls')  -- 启用 lua LSP
vim.lsp.enable("sqls")    -- 启用 MySQL LSP
vim.lsp.enable("pyright") -- 启用 Python LSP
vim.lsp.enable('bashls')  -- 启用 Shell 脚本 LSP
vim.lsp.enable("yamlls")  -- 启用 YAML LSP
vim.lsp.enable("jsonls")  -- 启用 JSON LSP

-- 全局诊断配置
vim.diagnostic.config {
    virtual_text     = true,  -- 代码旁显示错误信息
    underline        = true,  -- 下划线标记错误
    update_in_insert = false, -- 插入模式下不更新诊断
}

-- 全部诊断 → quickfix
vim.api.nvim_create_user_command("DiagnosticsProject", function()
    vim.diagnostic.setqflist({ open = true }) -- 纯 Lua 写法，自动打开 quickfix
end, { desc = "All diagnostics in quickfix" })

-- 当前 buffer（location list 窗口）
vim.api.nvim_create_user_command("DiagnosticsBuffer", function()
    vim.diagnostic.setloclist({ open = true }) -- 纯 Lua 写法，自动打开 loclist
end, { desc = "Current buffer diagnostics" })

-- 当前光标（浮窗显示）
vim.api.nvim_create_user_command("Diagnostics", function()
    vim.diagnostic.open_float() -- Lua 原生 API
end, { desc = "Cursor diagnostics" })


-- LSP Attach 时的按键绑定 & 命令
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local buf = args.buf
        local opts = { buffer = buf, noremap = true, silent = true }

        -- -------- 跳转相关 --------
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)      -- 跳转到定义
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)     -- 跳转到声明
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)  -- 跳转到实现
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts) -- 跳转到类型定义
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)      -- 查找引用

        -- -------- 提示相关 --------
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)              -- 光标悬停提示
        vim.keymap.set('i', '<C-S>', vim.lsp.buf.signature_help, opts) -- 函数签名提示

        -- 每个 buffer 一个 augroup，重复 attach 会自动清掉旧的
        vim.api.nvim_create_augroup('LspAutoCmds_' .. buf, { clear = true })
    end,
})

-- 告诉 LSP 'vim' 是全局变量
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
})


--- nvim-cmp ---
-- 自动补全配置
local cmp = require 'cmp'

cmp.setup {
    preselect = cmp.PreselectMode.Item,                    -- 自动高亮第一个候选项
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 回车确认选中
        -- Tab / Shift-Tab 切换候选项
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback() -- 菜单没打开就执行 Tab 原功能（缩进）
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback() -- 菜单没打开就执行 Shift-Tab 原功能
            end
        end, { 'i', 's' }),
    }),

    sources = {
        { name = 'nvim_lsp' }, -- LSP 补全
    },

    completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged }, -- 输入字符自动补全
    },

    -- 补全菜单加边框
    window = {
        completion = cmp.config.window.bordered({ border = "rounded" }),
        documentation = cmp.config.window.bordered({ border = "rounded" }),
    },
}


-- =========================
-- Help
-- =========================
-- 跳转相关:
-- gd  : 跳转到定义
-- gD  : 跳转到声明
-- gi  : 跳转到实现
-- gt  : 跳转到类型定义
-- gr  : 查找引用

-- 提示相关:
-- K   : 光标悬停提示
-- <C-S> : 函数签名提示

-- 代码操作:
-- gra : 代码操作（Code Action）
-- LspRename : 重命名符号

-- 增量选择:
-- an : 外层增量选择（outer incremental selection）
-- in : 内层增量选择（inner incremental selection）

-- 诊断相关:
-- ]d ,[d : 下一个/上一个诊断
-- ]D ,[D : 开始/结束诊断
