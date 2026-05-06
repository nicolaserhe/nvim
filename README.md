# Neovim Config

> 个人化 Neovim 0.12 配置：`vim.pack` 原生包管理 + `languages.lua` 集中式语言定义 + 命令行优先的工作流。

## 新机器部署

### 1. 系统依赖（手动装一次）

| 工具 | 需要方 |
|---|---|
| `tree-sitter` | nvim-treesitter |
| `cargo` | blink.cmp · protols |
| `ripgrep` | fzf-lua |
| `fd` | fzf-lua |
| `node` · `npm` | pyright · bash-language-server · yaml-language-server · json-lsp |
| `go` | gopls · delve |
| `python3` | debugpy |
| `wget` | Mason（下载） |
| `unzip` | Mason（解压） |
| `claude` | claudecode.nvim |

**可选**：

| 项 | 何时需要 |
|---|---|
| `DEEPSEEK_API_KEY` | minuet（未设时插件静默跳过） |

> Mason 会自动安装所有 LSP / 格式化 / 调试器 / 静态检查二进制（`gopls`, `clangd`, `lua-language-server`, `pyright`, `bash-language-server`, `yaml-language-server`, `json-lsp`, `marksman`, `protols`, `sqls`, `gofumpt`, `goimports`, `stylua`, `black`, `shfmt`, `buf`, `delve`, `codelldb`, `debugpy` 等），无需手动管理。
> `bootstrap.py` 末尾会 headless 触发并等待 Mason 完成（首次 5-15 分钟，含 codelldb ~70MB），所以你正式启动 nvim 时不会被下载阻塞 UI。
> 如果 bootstrap 后还有漏装（网络中断等），nvim 内跑 `:MasonToolsInstall` 强制重试，或 `:MasonInstall <pkg>` 点名装。

### 2. 克隆配置 + 安装插件

```bash
git clone https://github.com/<you>/nvim ~/.config/nvim
cd ~/.config/nvim
python bootstrap.py   # 30-60s 并行克隆所有插件，绕过 vim.pack 同步超时
nvim                  # 直接用；首次启动 nvim-treesitter 会自动编译 parser
```

`bootstrap.py` 自动从 lua 文件提取插件 URL 与 `version` 约束，并行处理：
- **缺失的**：`git clone --depth 1`，按约束 checkout 对应 tag
- **已存在的**：`git fetch` + 按约束 checkout 最高匹配 tag；无 pin 则 reset 到默认分支头
- **烂尾的**：清理空目录后重新 clone

每行输出：`↓` 新克隆 / `↻ a → b` 更新 / `✓` 已最新 / `✗` 失败。

可选参数：
```
./bootstrap.py -j 16     提高并行数（默认 8）
./bootstrap.py -f        强制全部 rm -rf 重克隆（不只是更新）
./bootstrap.py -h        帮助
```

日常更新插件两条路：
- `python bootstrap.py` —— 并行批量更新，包含 blink.cmp 重建 + Mason 同步，**适合机器闲时一键全量同步**
- `:lua vim.pack.update()` —— nvim 内交互更新，**日常增量推荐**

## 核心设计

- **包管理**：`vim.pack.add`（不依赖 lazy.nvim）
- **配置中心**：`lua/config/languages.lua` 一处定义所有语言的 LSP / TS / 格式化 / Linter / DAP
- **LSP**：0.11+ 原生 `vim.lsp.enable`，无 mason-lspconfig 中转
- **AI**：minuet-ai（Deepseek API ghost text）+ claudecode.nvim（Claude Code CLI 集成）
- **命令优先**：所有插件功能尽量暴露为 `:UserCommand`，按 `:` + Tab 或 `:FzfLua commands` 发现
- **懒加载**：dap / sql / claudecode / toggleterm 通过 `util.lazy` 在首次调用前不加载

## 目录结构

```
init.lua                          # 入口：vim.loader → settings → keymaps → autocmds → indent → plugins
queries/                          # 自定义 Treesitter 查询（go/c/cpp）
lua/
├── config/
│   ├── settings.lua              # vim.opt 全局选项
│   ├── keymaps.lua               # 全局快捷键（少量必要 leader 入口）
│   ├── autocmds.lua              # 全局 autocmd
│   ├── languages.lua             # 🔥 语言配置中心
│   ├── indent.lua                # 按 indent_mode 应用缩进
│   ├── theme.lua                 # 主题选择（dracula / dank）
│   └── highlights.lua            # 自定义高亮规则（用户自填）
├── util/
│   └── lazy.lua                  # 懒加载工具（on_cmd / on_keys / on_event）
└── plugins/
    ├── init.lua                  # 插件加载与懒加载注册
    ├── lsp/
    │   ├── servers.lua           # vim.lsp.enable 启用所有 server
    │   ├── keymaps.lua           # LspAttach 时挂 keymap + buffer-local user command
    │   ├── diagnostics.lua       # :Diagnostics 命令（接管走 trouble）
    │   ├── highlight.lua         # 光标停留时高亮同名符号（原生 LSP autocmd）
    │   ├── lazydev.lua           # nvim Lua 配置开发增强（仅 lua ft）
    │   └── completion.lua        # blink.cmp（含 minuet / lazydev 源）
    ├── ui/
    │   ├── theme.lua             # 派发：根据 config.theme 加载 dracula 或 dank
    │   ├── dankcolors.lua        # base16 + matugen 热重载（仅 dank 模式加载）
    │   ├── statusline.lua        # lualine
    │   ├── filetree.lua          # oil.nvim（buffer-as-directory）
    │   ├── dashboard.lua         # mini.starter（项目列表启动页）
    │   ├── git.lua               # gitsigns + diffview
    │   ├── trouble.lua           # 列表面板 UI（诊断/LSP/TODO 统一展示）
    │   └── render-markdown.lua   # markdown buffer 内渲染
    ├── editor/
    │   ├── treesitter.lua        # TS 安装 + 启动 + 用户高亮 hook
    │   ├── textobjects.lua       # treesitter 文本对象（af/if/ac/ic/aa/ia/al/il + ]m/[m）
    │   ├── pairs.lua             # autopairs / surround / Comment.nvim
    │   ├── picker.lua            # fzf-lua
    │   └── whichkey.lua          # which-key
    └── tools/
        ├── mason.lua             # mason + mason-tool-installer
        ├── format.lua            # conform.nvim
        ├── lint.lua              # nvim-lint
        ├── todo.lua              # todo-comments（TODO/FIX/HACK 高亮 + 搜索）
        ├── test.lua              # neotest（单测，adapter 由 languages.test 驱动）
        ├── grug-far.lua          # 项目级搜索替换面板（懒加载）
        ├── persistence.lua       # session 持久化
        ├── toggleterm.lua        # 浮动终端（懒加载）
        ├── dap.lua               # 调试器（懒加载）
        ├── sql.lua               # vim-dadbod-ui（懒加载）
        └── ai/
            ├── minuet.lua        # Deepseek ghost text
            └── claudecode.lua    # Claude Code CLI 集成（懒加载）
```

## 用户命令快查

> 不记命令？敲 `:` + Tab 自动补全；或 `:FzfLua commands` fuzzy 搜全集；或 `:command` 看完整列表。

### LSP / 诊断
| 命令 | 作用 |
|---|---|
| `:LspRename` | 重命名符号 |
| `:LspReferences` | 列引用 |
| `:LspIncomingCalls` / `:LspOutgoingCalls` | 调用链 |
| `:LspDocumentSymbols` | 文件符号 |
| `:LspImplementation` | 接口实现 |
| `:Diagnostics` | 当前光标处诊断（浮窗） |
| `:Diagnostics buffer` | 当前 buffer 诊断（trouble 面板） |
| `:Diagnostics project` | 全工作区诊断（trouble 面板） |
| `:LazyDev` | 查看当前 lua buffer 已加载的 library |

> 写 nvim Lua 配置时，`vim.api` / `vim.uv` / 插件 API（如 `require("trouble").*`）会被 lazydev 自动补全，仅 lua filetype 生效。

### 格式化 / Lint
| 命令 | 作用 |
|---|---|
| `:Format` | 全文格式化 |
| `:'<,'>Format` | 范围格式化 |
| `:ConformInfo` | 当前 buffer 可用 formatter |

### Picker (fzf-lua)
| 命令 | 作用 |
|---|---|
| `:FzfLua` | 选择器之选择器（picker of pickers） |
| `:FzfLua files` | 文件搜索 |
| `:FzfLua live_grep` | 全文 ripgrep |
| `:FzfLua oldfiles` | 最近文件（含 frecency 加权） |
| `:FzfLua buffers` | 打开的 buffer |
| `:FzfLua keymaps` | 所有 keymap（带 desc） |
| `:FzfLua commands` | 所有 user command |
| `:FzfLua command_history` | 命令历史 |
| `:FzfLua helptags` | 帮助标签 |
| `:FzfLua registers` | 寄存器（替代 registers.nvim） |
| `:FzfLua diagnostics_workspace` | 全工作区诊断 |
| `:FzfLua lsp_references` / `lsp_definitions` / `lsp_*` | LSP picker 集 |
| `:FzfLua git_files` / `git_status` / `git_*` | Git picker 集 |
| `:FzfLua dap_*` | DAP picker 集 |

### 列表面板 (trouble.nvim)
常驻面板风格的诊断 / LSP / quickfix / TODO 列表。与 fzf-lua 互补——浏览/扫多条用 trouble，模糊搜挑一条用 fzf-lua。

| 命令 | 作用 |
|---|---|
| `:Trouble diagnostics` | 全工作区诊断 |
| `:Trouble diagnostics filter.buf=0` | 仅当前 buffer |
| `:Trouble symbols` | document symbols 树形大纲 |
| `:Trouble lsp` | LSP 综合（refs/defs/impls/types） |
| `:Trouble lsp_references` / `lsp_definitions` / `lsp_*` | 单类 LSP 列表 |
| `:Trouble qflist` / `loclist` | 接管 quickfix / location list |
| `:TodoTrouble` | TODO 注释（来自 todo-comments 集成） |

> 面板内：`<CR>` 跳；`o` 跳并关闭；`q` 关；`r` 刷新；`?` 帮助。

### TODO 注释 (todo-comments)
注释里的关键词自动彩色高亮 + gutter sign。

| 关键词（别名） | 语义 |
|---|---|
| `TODO` | 待办 / 待实现，最通用的标记 |
| `FIX` (FIXME / BUG / FIXIT / ISSUE) | 已知 bug 或必须修复的代码，比 TODO 紧急 |
| `HACK` | 临时绕过 / 不优雅方案，提醒后人此处有妥协 |
| `WARN` (WARNING / XXX) | 警告 / 陷阱提醒，读到此处要小心 |
| `PERF` (OPTIM / PERFORMANCE / OPTIMIZE) | 性能相关备注，可能的优化点或瓶颈 |
| `NOTE` (INFO) | 重要上下文 / 给后续读者的说明 |
| `TEST` (TESTING / PASSED / FAILED) | 测试相关 / 临时调试代码标记 |

| 命令 | 作用 |
|---|---|
| `:TodoFzfLua` | fzf-lua 搜索全项目 TODO（推荐） |
| `:TodoFzfLua keywords=TODO,FIX` | 按关键词过滤 |
| `:TodoQuickFix` | TODO 进 quickfix（`:cnext`/`:cprev` 跳转） |
| `:TodoLocList` | TODO 进 location list |

### 项目搜索替换 (grug-far)
一个 buffer 同时管搜索词 / 替换词 / glob/regex/case 选项 / 实时预览，确认后一次写入所有文件。重构改名利器。

| 命令 | 作用 |
|---|---|
| `:GrugFar` | 打开搜索替换面板 |
| `:'<,'>GrugFarVisual` | (visual) 用选区作为初始搜索词 |
| `:GrugFarWithin` | 仅当前 buffer 搜索 |
| `:'<,'>GrugFarWithinVisual` | visual 选区 + 仅当前 buffer |

> 面板内 `<localleader>r` 执行替换；`w` 全词；`x` 大小写；`q`/`l` 进 quickfix/loclist；`c` 关闭。
> 与 fzf-lua live_grep 区别：fzf-lua 找一个位置跳过去；grug-far 看全部匹配 + 预览替换 + 批量写入。

### Markdown 渲染 (render-markdown)
在 buffer 里直接渲染 markdown：标题彩色、代码块边框、列表 bullet、表格对齐、`- [ ]` ☐ / `- [x]` ☑。光标当前行临时显示原始语法。

| 命令 | 作用 |
|---|---|
| `:RenderMarkdown` | 全局 toggle 渲染 |
| `:RenderMarkdown enable` / `disable` | 全局开/关 |
| `:RenderMarkdown buf_toggle` / `buf_enable` / `buf_disable` | 仅当前 buffer |

### Session
| 命令 | 作用 |
|---|---|
| `:PersistenceLoad` | 加载当前 cwd session |
| `:PersistenceLoadLast` | 加载最近 session |
| `:PersistenceSelect` | 选择 session |
| `:PersistenceSave` | 手动保存 |
| `:PersistenceStop` | 本次退出不保存 |

### 文件浏览
| 命令 | 作用 |
|---|---|
| `:Oil` | 在当前文件目录打开 oil buffer |
| `:Oil <path>` | 在指定路径打开 |
| `:Starter` | 启动页（Projects 节列出最近用过的项目，选中即 cd + 加载 session） |

### 终端 (toggleterm)
| 命令 | 作用 |
|---|---|
| `:ToggleTerm` | 切换 1 号终端 |
| `:1ToggleTerm` … `:5ToggleTerm` | 切换指定终端 |
| `:TermSelect` | 终端选择器 |

### 调试 (dap)
| 命令 | 作用 |
|---|---|
| `:DapContinue` | 启动 / 继续 |
| `:DapStepOver` / `:DapStepInto` / `:DapStepOut` | 单步 |
| `:DapBreakpoint` | 切换断点 |
| `:DapBreakpointCondition` | 条件断点 |
| `:DapTerminate` | 终止 |
| `:DapREPL` | REPL |
| `:DapRunLast` | 重跑上次 |
| `:DapUIToggle` | 切换 DAP UI |
| `:'<,'>DapEval` | (visual) 求值选区 |

### 测试 (neotest)
跑单元测试 / 集成测试（即"单测"）。adapter 由 `languages.lua` 的 `test` 字段驱动，目前装了 `neotest-go`。

| 命令 | 作用 |
|---|---|
| `:Neotest run` | 跑光标处测试 |
| `:Neotest run file` | 跑当前文件 |
| `:Neotest run last` | 重跑上次 |
| `:Neotest run dap` | 跑光标处 + 进入 dap 调试 |
| `:Neotest stop` | 停止当前测试 |
| `:Neotest summary toggle` | 侧边栏（树形 + pass/fail 状态） |
| `:Neotest output` | 当前测试输出（浮窗） |
| `:Neotest output-panel toggle` | 持久 output 面板 |
| `:Neotest jump next` / `prev` | 跳到下/上一个测试 |

> summary 面板内：`r` 跑 / `d` 调试 / `o` 看 output / `s` 停 / `m` 标记 / `<CR>` 跳源码。

### 数据库 (dadbod)
| 命令 | 作用 |
|---|---|
| `:DBUI` | 打开侧边栏 |
| `:DBUIToggle` | 切换显示 |
| `:DBUIAddConnection` | 添加连接 |

### AI
| 命令 | 作用 |
|---|---|
| `:MinuetToggle` | 开关 Deepseek ghost text |
| `:ClaudeCode` | 切换 Claude Code 浮窗 |
| `:ClaudeCodeFocus` | focus 到 Claude 终端 |
| `:ClaudeCodeStart` / `:ClaudeCodeStop` | 启停 Claude 实例 |
| `:ClaudeCodeStatus` | 连接状态 |
| `:ClaudeCodeSend` | 发送选区给 Claude |
| `:ClaudeCodeAdd <file>` | 加文件到上下文 |
| `:ClaudeCodeDiffAccept` / `:ClaudeCodeDiffDeny` | 接受 / 拒绝 diff |

### Mason
| 命令 | 作用 |
|---|---|
| `:Mason` | 打开 Mason UI |
| `:MasonInstall <pkg>` | 安装包 |
| `:MasonUninstall <pkg>` | 卸载包 |
| `:MasonUpdate` | 更新已安装包 |

### Git
| 命令 | 作用 |
|---|---|
| `:Gitsigns stage_hunk` / `reset_hunk` / `blame_line` | gitsigns 子命令 |
| `:DiffviewOpen` | 打开 diff 视图 |
| `:DiffviewClose` | 关闭 |
| `:DiffviewFileHistory %` | 当前文件历史 |

### 其他
| 命令 | 作用 |
|---|---|
| `:WhichKey` | 手动触发 keymap 提示 |
| `:command` | 列所有 user command |
| `:checkhealth` | 整体健康检查 |
| `:lua require("config.languages").show_stats()` | 配置统计 |

## 快捷键

设计原则：keymap 仅服务高频操作，其他走 `:UserCommand`。按下 `<leader>` 后 300ms which-key 弹提示。

### 全局
| 键 | 作用 |
|---|---|
| `]t` / `[t` | 上下个 tab |
| `]b` / `[b` | 上下个 buffer |
| `]q` / `[q` | 上下个 quickfix |
| `]c` / `[c` | 上下个 git hunk（gitsigns，或 diff 模式原生） |
| `<leader>ff` | FzfLua files |
| `<leader>fg` | FzfLua live_grep |
| `<leader>fc` | FzfLua commands |

> args 列表切换用 `:n` / `:N`（操作低频，不绑 keymap）；`]a` / `[a` 让位给下面的参数 motion。

### 文本对象（treesitter-textobjects）
配合 `d`/`y`/`c`/`v` 操作符使用，例：`daf` 删整个函数、`vif` 选函数体、`yac` yank 整个 class。

| 键 | 作用 |
|---|---|
| `af` / `if` | 整个 / 内部 function |
| `ac` / `ic` | 整个 / 内部 class |
| `aa` / `ia` | 整个 / 内部参数 |
| `al` / `il` | 整个 / 内部 loop |
| `]m` / `[m` | 下/上一个 function 开头（增强 vim 内置，跨语言） |
| `]M` / `[M` | 下/上一个 function 结尾 |
| `]a` / `[a` | 下/上一个参数 |

### LSP（buffer-local）
| 键 | 作用 |
|---|---|
| `gd` / `gD` / `gt` | 定义 / 声明 / 类型定义 |
| `K` | 悬停文档 |
| `<C-S>` (insert) | 函数签名 |
| `gra` | 代码操作（Neovim 内置） |

### 终端 (toggleterm)
| 键 | 作用 |
|---|---|
| `<C-\>` | 切换 1 号终端 |
| `<leader>1-5` | 切换 1-5 号终端（普通+终端模式） |
| `<leader>tt` | 终端选择器 |
| `<Esc>` (term mode) | 退出终端模式 |

### 调试 (dap)
| 键 | 作用 |
|---|---|
| `<leader>de` (visual) | 求值选区 |

### Insert 模式 - AI ghost text (minuet)
| 键 | 作用 |
|---|---|
| `<A-y>` | 接受全部 |
| `<A-l>` | 接受一行 |
| `<A-]>` / `<A-[>` | 切候选 |
| `<A-e>` | 关闭 |

### Insert 模式 - 补全 (blink.cmp)
| 键 | 作用 |
|---|---|
| `<CR>` | 确认 |
| `<C-N>` / `<C-P>` | 下/上 |
| `<Tab>` / `<S-Tab>` | snippet 跳转 |
| `<C-Space>` | 手动触发 |
| `<C-U>` / `<C-D>` | 文档滚动 |

### oil（仅在 oil buffer 内）
| 键 | 作用 |
|---|---|
| `<CR>` | 选中（打开/进入） |
| `-` | 上级目录 |
| `_` | cwd |
| `q` | 关闭 |
| `g?` | 帮助 |
| `g.` | 切换隐藏文件 |
| `<C-s>` / `<C-h>` | 垂直 / 水平分割打开 |
| `<C-p>` | 预览 |

## 添加新语言

只编辑 `lua/config/languages.lua`：

```lua
LANGUAGES = {
    rust = {
        lsp        = "rust_analyzer",            -- LSP 服务器
        treesitter = true,                       -- 启用 TS
        -- treesitter_parser = "...",            -- parser 名与 ft 不同时填
        -- treesitter_extra_parsers = { "..." }, -- 额外 parser（如 markdown 配套 markdown_inline）
        indent_mode = "smartindent",
        formatters = { "rustfmt" },
        format_on_save = true,
        linters    = { "clippy" },
        dap = {                                  -- DAP 调试（可选）
            adapter = "codelldb",
            mason   = "codelldb",
        },
        test = {                                 -- neotest 测试（可选）
            adapter = "neotest-rust",            -- require 名 + 默认 URL https://github.com/nvim-neotest/<adapter>
            -- src  = "https://github.com/non-nvim-neotest/...",  -- 仅在非 nvim-neotest org 时填
            -- opts = { ... },                   -- adapter 实例化选项
        },
    },
}

-- 共享 server 配置（c/cpp 共用 clangd 这种场景）
LSP_CONFIGS = {
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = { ... },
        },
    },
}
```

重启后 mason 自动装；DAP 在你第一次跑 `:DapContinue` 时按需加载。

## 主题切换

```lua
-- lua/config/theme.lua
return {
    active = "dracula",   -- "dracula" | "dank"
}
```

切到 `"dank"` 后重启使用 base16。`dankcolors.lua` 自带 fs 监听器：matugen 每次重写本文件都会自动应用新配色。

## 自定义高亮

填进 `lua/config/highlights.lua` 的 `M.apply()`：

```lua
function M.apply()
    vim.api.nvim_set_hl(0, "@function",  { fg = "#f5a97f" })
    vim.api.nvim_set_hl(0, "@type",      { fg = "#eed49f", bold = true })
    -- ...
end
```

`M.apply()` 在每次 `:colorscheme` 后自动重跑，主题切换时不会丢。

## 启动优化

- `vim.loader.enable()`：Lua 字节码缓存（cache 在 `~/.cache/nvim/luac/`）
- 懒加载：dap / sql / claudecode / toggleterm 在第一次相关命令或按键之前不加载

冷启动约 130ms（含全部 UI/LSP/补全初始化）。

## 调试与维护

```vim
:checkhealth                       " 整体健康
:Mason                             " 已装工具
:ConformInfo                       " formatter 状态
:lua require("config.languages").show_stats()
:lua vim.pack.update()             " 更新插件 + 清理废弃包
```

## License

MIT
