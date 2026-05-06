-- ============================================================
-- Git 集成：行级变更（gitsigns）& diff 视图（diffview）
-- ============================================================
vim.pack.add {
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/sindrets/diffview.nvim" },
}

-- ── gitsigns ─────────────────────────────────────────────
require("gitsigns").setup {
    on_attach = function(bufnr)
        local gs  = require("gitsigns")
        local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
        end

        -- hunk 导航（在 diff 模式下保持原生跳转）
        bmap("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gs.nav_hunk("next")
            end
        end, "Git: next hunk")
        bmap("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gs.nav_hunk("prev")
            end
        end, "Git: prev hunk")
    end,
}

-- ── 快捷键说明 ────────────────────────────────────────────
-- ]c / [c                          跳转到下 / 上一个 hunk
-- :Gitsigns stage_hunk             Stage 当前 hunk
-- :Gitsigns undo_stage_hunk        取消 stage 当前 hunk
-- :Gitsigns reset_hunk             还原当前 hunk
-- :Gitsigns blame_line             当前行 blame 详情
-- :Gitsigns toggle_current_line_blame  开关行内 blame
-- :Gitsigns toggle_word_diff       开关逐词 diff
-- :DiffviewOpen                    打开项目 diff 视图
-- :DiffviewClose                   关闭 diff 视图
-- :DiffviewFileHistory %           当前文件 commit 历史
