-- =========================
-- Add Plugin
-- =========================
vim.pack.add {
    { src = 'https://github.com/mfussenegger/nvim-dap' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/rcarriga/nvim-dap-ui' },
    { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
    { src = 'https://github.com/leoluz/nvim-dap-go' },
}


-- =========================
-- Setup / Config
-- =========================
require("dapui").setup {}
require('dap-go').setup {}

-- local dap = require("dap")
local dapui = require("dapui")

-- UI 快捷键
vim.api.nvim_create_user_command("DapUIOpen", function()
    dapui.open()
end, {})

vim.api.nvim_create_user_command("DapUIClose", function()
    dapui.close()
end, {})

vim.keymap.set("v", "<leader>de", dapui.eval) -- 评估选中变量


-- =========================
-- Help
-- =========================
