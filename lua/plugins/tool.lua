-- =========================
-- Add Plugin
-- =========================
vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },   -- Mason 工具管理器
    { src = "https://github.com/stevearc/conform.nvim" },  -- 格式化程序
    { src = "https://github.com/mfussenegger/nvim-lint" }, -- 静态分析
    { src = "https://github.com/RRethy/vim-illuminate" },  -- 高亮光标下单词
})

-- =========================
-- Setup / Config
-- =========================
-- --- mason.nvim ---
require("mason").setup {}

-- --- conform.nvim ---
require("conform").setup {
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_format = "fallback",
    },

    formatters_by_ft = {
        go = { "gofumpt", "goimports" }, -- 顺序执行：先 gofumpt，再 goimports
    },
}

-- --- nvim-lint ---
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     callback = function()
--         -- try_lint without arguments runs the linters defined in `linters_by_ft`
--         -- for the current filetype
--         require("lint").try_lint()
--
--         -- You can call `try_lint` with a linter name or a list of names to always
--         -- run specific linters, independent of the `linters_by_ft` configuration
--         -- require("lint").try_lint("cspell")
--     end,
-- })

require('lint').linters_by_ft = {
    go = { 'staticcheck' },
}

-- --- illuminate ---
require('illuminate').configure({
    -- 只在普通模式启用高亮
    modes_allowlist = { 'n' },
})


-- =========================
-- Help
-- =========================
