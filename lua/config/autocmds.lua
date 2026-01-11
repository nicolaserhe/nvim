-- =======================================================
-- 自动命令模块
-- =======================================================


-- ------------------------
-- 保存上次编辑位置
-- ------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*", -- 对所有文件生效
    callback = function()
        -- 获取上次光标位置
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)

        -- 如果上次光标行合法，则跳转
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})
