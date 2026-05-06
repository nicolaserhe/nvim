-- ============================================================
-- 全局编辑器选项
-- ============================================================
local o = vim.opt

-- 界面与显示
o.number = true -- 行号
o.cursorline = true -- 高亮当前行
o.signcolumn = "yes" -- 固定左侧标记列，避免文本跳动
o.termguicolors = true -- 真彩色
o.scrolloff = 8 -- 光标距屏幕边缘保留 8 行
o.wrap = true -- 自动换行
o.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:block,o:block" -- 所有模式使用块状光标
o.splitbelow = true -- 水平分割：新窗口在下
o.splitright = true -- 垂直分割：新窗口在右
o.wildmode = "full" -- Tab 从第一个开始循环；回车确认

-- 缩进
o.tabstop = 4 -- Tab 显示宽度
o.shiftwidth = 4 -- >> / << 缩进宽度
o.softtabstop = 4 -- 插入模式 Tab 步长
o.expandtab = true -- Tab 展开为空格
o.smartindent = true -- 根据语法自动缩进

-- 搜索
o.hlsearch = true -- 高亮所有匹配项
o.incsearch = true -- 输入时实时显示匹配
o.ignorecase = true -- 默认忽略大小写
o.smartcase = true -- 含大写字母时区分大小写
o.shortmess:append("S") -- 不在命令行显示搜索计数

-- 性能
o.updatetime = 100 -- CursorHold 触发间隔（ms），影响诊断刷新速度

-- 文件 & 缓冲区
o.backup = false -- 不生成 .bak 文件
o.writebackup = false -- 写入时不生成备份
o.hidden = true -- 允许切换未保存的缓冲区
o.autoread = true -- 外部修改后自动重新加载
o.confirm = true -- 退出前提示保存
