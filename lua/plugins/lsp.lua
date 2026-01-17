-- =========================
-- Plugin 管理
-- =========================
vim.pack.add {
    { src = 'https://github.com/neovim/nvim-lspconfig' }, -- LSP 配置
    { src = 'https://github.com/hrsh7th/nvim-cmp' },      -- 补全框架
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },  -- LSP 补全源
}

-- =========================
-- LSP 配置
-- =========================
local lsp = vim.lsp

-- 启用 LSP
local servers = {
    'gopls',   -- Go
    'clangd',  -- C/CPP
    'lua_ls',  -- Lua
    'sqls',    -- SQL
    'pyright', -- Python
    'bashls',  -- Shell
    'yamlls',  -- YAML
    'jsonls',  -- JSON
}

for _, srv in ipairs(servers) do
    lsp.enable(srv)
end

-- Lua 特殊配置
lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }, -- 告诉 LSP 'vim' 是全局变量
            },
        },
    },
})

-- =========================
-- LSP Attach buffer-local 快捷键 & 命令
-- =========================
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local buf = args.buf
        local opts = { buffer = buf, noremap = true, silent = true }

        -- ---------- 跳转 ----------
        vim.keymap.set('n', 'gd', lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gt', lsp.buf.type_definition, opts)

        -- ---------- 提示 ----------
        vim.keymap.set('n', 'K', lsp.buf.hover, opts)
        vim.keymap.set('i', '<C-S>', lsp.buf.signature_help, opts)

        -- ---------- buffer-local 命令 ----------
        local function buf_cmd(name, fn, cmd_opts)
            vim.api.nvim_buf_create_user_command(buf, name, fn, cmd_opts or {})
        end

        buf_cmd('LspReferences', lsp.buf.references)
        buf_cmd('LspIncomingCalls', lsp.buf.incoming_calls)
        buf_cmd('LspOutgoingCalls', lsp.buf.outgoing_calls)
        buf_cmd('LspDocumentSymbols', lsp.buf.document_symbol)
        buf_cmd('LspImplementation', lsp.buf.implementation)
        buf_cmd('LspRename', function() lsp.buf.rename() end, { nargs = 0 })
    end,
})

-- =========================
-- 全局诊断配置
-- =========================
vim.diagnostic.config {
    virtual_text     = true,  -- 代码旁显示错误信息
    underline        = true,  -- 下划线标记错误
    update_in_insert = false, -- 插入模式下不更新诊断
}

-- 全局诊断命令
vim.api.nvim_create_user_command("Diagnostics", function(opts)
    local scope = opts.args
    if scope == "project" then
        vim.diagnostic.setqflist({ open = true })
    elseif scope == "buffer" then
        vim.diagnostic.setloclist({ open = true })
    else
        -- 默认或 unknown 都执行光标诊断
        vim.diagnostic.open_float()
    end
end, {
    desc = "Show diagnostics: project/buffer (default: cursor)",
    nargs = "?", -- 可选参数
})

-- =========================
-- nvim-cmp 自动补全
-- =========================
local cmp = require 'cmp'

cmp.setup {
    -- ---------- 基本配置 ----------
    preselect = cmp.PreselectMode.Item, -- 自动高亮第一个候选项

    -- ---------- 快捷键映射 ----------
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 回车确认选中项
    }),

    -- ---------- 补全来源 ----------
    sources = {
        { name = 'nvim_lsp' }, -- 使用 LSP 提供补全
    },

    -- ---------- 自动触发补全 ----------
    completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged }, -- 输入字符时自动补全
    },

    -- ---------- 补全窗口样式 ----------
    window = {
        completion    = cmp.config.window.bordered({ border = "rounded" }), -- 补全菜单加圆角边框
        documentation = cmp.config.window.bordered({ border = "rounded" }), -- 文档浮窗加圆角边框
    },
}

-- =========================
-- 快捷键 & 使用说明（仅注释）
-- =========================
--- ---------- 跳转 ----------
-- gd  : 跳转到定义 (vim.lsp.buf.definition)
-- gD  : 跳转到声明 (vim.lsp.buf.declaration)
-- gt  : 跳转到类型定义 (vim.lsp.buf.type_definition)

-- ---------- 提示 ----------
-- K     : 光标悬停提示 (vim.lsp.buf.hover)
-- <C-S> : 函数签名提示 (vim.lsp.buf.signature_help)

-- ---------- 代码操作 ----------
-- gra       : 代码操作 (Code Action)
-- :LspRename : 重命名符号 (vim.lsp.buf.rename)
-- :LspReferences      : 当前符号引用 (vim.lsp.buf.references)
-- :LspIncomingCalls   : 函数被调用的地方 (vim.lsp.buf.incoming_calls)
-- :LspOutgoingCalls   : 函数调用了哪些函数 (vim.lsp.buf.outgoing_calls)
-- :LspDocumentSymbols : 当前 buffer 中的符号列表 (vim.lsp.buf.document_symbol)
-- :LspImplementation  : 当前接口实现 (vim.lsp.buf.implementation)

-- ---------- 增量选择 ----------
-- an : 外层增量选择 (outer incremental selection)
-- in : 内层增量选择 (inner incremental selection)

-- ---------- 诊断 ----------
-- ]d ,[d : 下一个/上一个诊断
-- ]D ,[D : 开始/结束诊断
-- :Diagnostics          : 光标诊断 (默认)
-- :Diagnostics buffer   : 当前 buffer 诊断 → location list
-- :Diagnostics project  : 全项目诊断 → quickfix
