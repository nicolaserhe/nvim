-- ============================================================
-- 代码格式化（conform.nvim）
-- 根据 languages.lua 配置决定是否保存时自动格式化
-- ============================================================
vim.pack.add {
    { src = "https://github.com/stevearc/conform.nvim" },
}

-- 从语言配置加载 formatters
local languages = require("config.languages")

require("conform").setup {
    -- 根据文件类型动态决定是否保存时自动格式化
    format_on_save = function(bufnr)
        -- 获取当前 buffer 的文件类型
        local filetype = vim.bo[bufnr].filetype

        -- 检查该文件类型是否配置为保存时自动格式化
        if languages.should_format_on_save(filetype) then
            return {
                timeout_ms = 500,
                lsp_format = "fallback",
            }
        end

        -- 不自动格式化，返回 nil
        return nil
    end,

    formatters_by_ft = languages.get_formatters_by_ft(),
}

-- 注册 :Format 命令，支持全文及可视范围格式化
vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, #end_line },
        }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

-- ── 常用命令 ─────────────────────────────────────────────
-- :ConformInfo  查看当前 buffer 可用的 formatter
-- :Format       手动触发格式化（无论是否启用自动格式化）
--
-- ── 配置说明 ─────────────────────────────────────────────
-- 在 lua/config/languages.lua 中为每种语言设置 format_on_save:
--   format_on_save = true   保存时自动格式化
--   format_on_save = false  仅手动格式化（默认）
--
-- 示例：
--   go = {
--       formatters = { "gofumpt", "goimports" },
--       format_on_save = true,  -- Go 代码保存时自动格式化
--   },
--   lua = {
--       formatters = { "stylua" },
--       format_on_save = false, -- Lua 代码仅手动格式化
--   },
