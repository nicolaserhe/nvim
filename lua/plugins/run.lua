-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    { src = 'https://github.com/CRAG666/code_runner.nvim' },
}


-- =========================
-- Setup / Config
-- =========================
require('code_runner').setup {
    filetype = {
        go = "go run .",
    },
    focus = false, -- 执行后是否聚焦终端
}


-- =========================
-- Help
-- =========================
-- :RunCode - 根据文件类型运行当前文件（先检查项目，再查文件类型映射）
-- :RunClose - 关闭正在运行的程序（better_term 模式下无效，使用原生终端）
