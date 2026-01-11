-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-frecency.nvim' },
    -- { src = 'https://github.com/nvim-telescope/telescope-dap.nvim' },
}


-- =========================
-- Setup / Config
-- =========================
require("telescope").setup {
    defaults = {},
    extensions = {
        ["ui-select"] = require("telescope.themes").get_dropdown {},
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
}

-- 加载扩展
require("telescope").load_extension("ui-select")
require("telescope").load_extension("fzf")
require('telescope').load_extension('frecency')
-- require('telescope').load_extension('dap')


-- =========================
-- Help
-- =========================
-- :checkhealth telescope     -- 检查 Telescope 插件的安装和设置是否正确

-- :Telescope find_files      -- 在指定目录中查找文件，可以快速打开文件
-- :Telescope live_grep       -- 在项目或指定目录中实时搜索文本内容（类似 grep），支持跳转到匹配行
-- :Telescope buffers         -- 列出当前已打开的缓冲区（文件），方便快速切换文件
-- :Telescope frecency        -- 按访问频率和最近使用时间列出文件
