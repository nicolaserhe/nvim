-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
}


-- =========================
-- Setup / Config
-- =========================
require 'nvim-treesitter'.setup {
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
}

-- 确保 parser 安装
require 'nvim-treesitter'.install { 'go', 'c' }
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"


vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'go', 'c' },
    callback = function()
        vim.api.nvim_set_hl(0, "@comment", { fg = "#c6a0f6", bold = false })
        vim.api.nvim_set_hl(0, "@function", { fg = "#f5a97f", bold = false })
        vim.api.nvim_set_hl(0, "@type", { fg = "#eed49f", bold = false })
        vim.api.nvim_set_hl(0, "@string", { fg = "#a6da95", bold = false })
        vim.api.nvim_set_hl(0, "@number", { fg = "#a6da95", bold = false })
        vim.api.nvim_set_hl(0, "@variable.definition", { fg = "#8aadf4", bold = false })
        vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#8aadf4", bold = false })
        vim.api.nvim_set_hl(0, "@constant", { fg = "#8aadf4", bold = false })
        vim.api.nvim_set_hl(0, "@operator", { fg = "#6e738d", bold = false })

        vim.treesitter.start()
    end,
})




-- =========================
-- Help
-- =========================
