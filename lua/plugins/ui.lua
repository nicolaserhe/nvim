-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    -- theme --
    -- { src = 'https://github.com/catppuccin/nvim' },
    { src = 'https://github.com/Mofiqul/dracula.nvim' },

    -- neo-tree --
    {
        src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
        version = vim.version.range('3')
    },

    -- nvim-bqf --
    { src = 'https://github.com/kevinhwang91/nvim-bqf' },

    -- Alpha --
    { src = 'https://github.com/goolord/alpha-nvim' },

    -- session --
    { src = 'https://github.com/Shatur/neovim-session-manager' },

    -- dependencies --
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },

    -- lualine.nvim --
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },

    -- gitsigns.nvim --
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },

    -- diffview.nvim --
    { src = 'https://github.com/sindrets/diffview.nvim' },
}


-- =========================
-- Setup / Config
-- =========================
-- --- catppuccin ---
-- require("catppuccin").setup {
--     flavour = "macchiato", -- latte / frappe / macchiato / mocha
--     integrations = {
--         diffview = true,   -- 必须为 true
--     },
-- }
-- vim.cmd.colorscheme "catppuccin"

-- --- dracula ---
vim.cmd.colorscheme "dracula"


-- --- neo-tree ---
require("neo-tree").setup {
    source_selector = {
        winbar = true,
        statusline = false,
    },

    default_component_configs = {
        git_status = {
            symbols = {
                added     = "",
                deleted   = "",
                modified  = "",
                renamed   = "",
                untracked = "",
                ignored   = "",
                unstaged  = "",
                staged    = "",
            },
            align = "right",
        },
    },
    window = {
        mappings = {

        }
    }
}


-- --- alpha ---
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
-- Buttons
dashboard.section.buttons.val = {
    dashboard.button("o", "󰏖  Open Last Session", ":SessionManager load_last_session<CR>"),
    dashboard.button("s", "  Choose Session", ":SessionManager load_session<CR>"),
    dashboard.button("f", "  Frecency files", "::Telescope frecency<CR>"),
    dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
}
dashboard.config.opts.noautocmd = true
alpha.setup(dashboard.config)

-- --- session_manager ---
local session_manager = require("session_manager")
local config = require("session_manager.config")
session_manager.setup {
    autoload_mode = config.AutoloadMode.Disabled,
}

-- 退出 Neovim 之前删除不在当前工作目录的 buffer
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        local cwd = vim.fn.getcwd()
        local cur_buf = vim.api.nvim_get_current_buf() -- 当前 buffer
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                local bufname = vim.api.nvim_buf_get_name(buf)
                -- 排除空 buffer 和当前 buffer
                if bufname ~= "" and buf ~= cur_buf and not vim.startswith(bufname, cwd) then
                    -- 删除 buffer
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end
        end
    end,
})

-- --- lualine.nvim --
local lsp_server = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 }) -- 获取当前 buffer 的 LSP
    if #clients == 0 then
        return ""                                      -- 没有 LSP 就显示空
    end

    local names = {}
    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end

    return " " .. table.concat(names, ", ") .. string.rep(" ", 16)
end

local linecol = function()
    local unpack = table.unpack or unpack
    local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- 当前行列
    local total = vim.api.nvim_buf_line_count(0)            -- 总行数
    return string.format(":%d/%d :%d ", row, total, col + 1)
end
require("lualine").setup {
    options = {
        globalstatus = true,
    },

    sections = {
        -- 左侧状态栏
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        -- 右侧状态栏
        lualine_x = { { lsp_server, separator = '' }, 'filetype' },
        lualine_y = {
            { 'encoding', separator = '' },
            { 'fileformat', symbols = { unix = ' ', dos = ' ' } },
            { 'searchcount', separator = '' },
            { 'selectioncount', separator = '' },
        },
        lualine_z = {
            { 'progress', separator = '' },
            { linecol,    separator = '', padding = 0 },
        },
    },

    tabline = {
        lualine_a = { 'buffers' }, -- 左侧显示 buffer 列表
        lualine_z = { 'tabs' },    -- 右侧显示 tab 列表
    },

    extensions = {
        'nvim-tree', -- 在 Nvim-Tree 窗口显示简洁状态栏
        'quickfix',  -- 在 Quickfix 窗口显示状态栏
    },
}


-- --- gitsigns.nvim ---
require('gitsigns').setup {
    on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal({ ']c', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end)

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal({ '[c', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end)
    end
}


-- =========================
-- Help
-- =========================
-- --- Neo-tree.nvim ---
-- 文件/目录操作
-- <space> 节点展开/收缩
-- z       关闭所有节点
-- R       刷新
-- a       添加文件
-- A       添加目录
-- d       删除文件
-- r       重命名文件
-- y       复制到剪切板
-- x       剪切到剪切板
-- p       从剪切板粘贴
-- <C-r>   清空剪切板
-- c       复制文件
-- m       移动文件
-- <       切换到上一个 source
-- >       切换到下一个 source
-- H       显示/隐藏隐藏文件
-- i       显示文件详情
-- b       重命名文件名（basename）
-- D       删除缓冲区

-- Git 操作
-- ga      Git 添加当前文件
-- A       Git 添加全部文件
-- gu      取消暂存文件
-- gU      撤销最后一次提交
-- gt      切换文件暂存状态
-- gr      Git 恢复文件
-- gc      Git 提交
-- gp      Git 推送
-- gg      提交并推送


-- --- gitsigns.nvim ---
-- 导航：
--   ]c       - 跳到下一个 Git hunk
--   [c       - 跳到上一个 Git hunk
--
-- Git 操作：
--   :Gitsigns stage_hunk                   - stage 当前 hunk
--   :Gitsigns undo_stage_hunk              - unstage当前 hunk
--   :Gitsigns reset_hunk                   - reset 当前 hunk
--   :Gitsigns blame_line                   - 显示当前行 Git blame（完整信息）
--   :Gitsigns toggle_current_line_blame    - 显示/隐藏当前行 blame
--   :Gitsigns toggle_word_diff             - 开启/关闭 word diff（逐字 diff）
--
