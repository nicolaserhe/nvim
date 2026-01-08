-- =========================
-- Add Plugin
-- =========================
vim.pack.add{
    { src = 'https://github.com/windwp/nvim-autopairs' },
    { src = 'https://github.com/numToStr/Comment.nvim' },
    { src = 'https://github.com/tversteeg/registers.nvim' },
}


-- =========================
-- Setup / Config
-- =========================
require('nvim-autopairs').setup({})
require('registers').setup({})


-- =========================
-- Help
-- =========================
