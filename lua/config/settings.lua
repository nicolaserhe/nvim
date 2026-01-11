-- =======================================================
-- 基础设置模块
-- =======================================================
local o = vim.opt


-- ------------------------
-- 界面和显示
-- ------------------------
o.number = true                                              -- 显示行号
o.cursorline = true                                          -- 高亮当前行
o.signcolumn = "yes"                                         -- 左侧标记列固定显示（诊断信息不会移动文本）
o.termguicolors = true                                       -- 启用真彩色支持
o.scrolloff = 8                                              -- 光标上下至少保持8行可视
o.wrap = true                                                -- 自动换行
o.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:block,o:block" -- 光标样式：块状

-- ------------------------
-- 缩进和制表符
-- ------------------------
o.tabstop = 4        -- Tab 显示宽度为4空格
o.shiftwidth = 4     -- 自动缩进宽度4
o.softtabstop = 4    -- 插入模式下Tab长度4
o.expandtab = true   -- 用空格代替Tab
o.smartindent = true -- 根据代码结构自动缩进

-- ------------------------
-- 搜索设置
-- ------------------------
o.hlsearch = true       -- 高亮搜索结果
o.incsearch = true      -- 实时显示匹配结果
o.ignorecase = true     -- 搜索忽略大小写
o.smartcase = true      -- 输入大写字母时匹配大小写
o.shortmess:append("S") -- 不在命令行显示搜索匹配计数

-- ------------------------
-- 补全设置
-- ------------------------
o.updatetime = 100 -- CursorHold 事件触发时间(ms)

-- ------------------------
-- 文件和缓存
-- ------------------------
o.backup = false      -- 不生成备份文件
o.writebackup = false -- 保存时不生成备份
o.hidden = true       -- 允许切换未保存缓冲区
o.autoread = true     -- 文件被外部修改时自动加载
o.confirm = true      -- 未保存修改退出/切换时提示确认
