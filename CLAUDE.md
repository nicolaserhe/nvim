# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Neovim 0.12+ configuration (Lua), not application code. There is no build / test / package step; "verification" means making sure the config still loads.

## Architecture invariants (read before editing)

### `lua/config/languages.lua` is the single source of truth
All language behavior — LSP server, Treesitter parser (incl. `treesitter_extra_parsers` for siblings like `markdown_inline`), formatter, linter, DAP adapter, neotest adapter, indent mode, format-on-save — is declared per language in `LANGUAGES`. Adding or modifying a language happens **only** here; the plugin files loop over `M.get_*()` helpers. Do not hard-code per-language behavior inside individual plugin files.

Server-level config (e.g. clangd's `on_attach`) lives in the top-level `LSP_CONFIGS = { <server> = {...} }` table in the same file, **not** as a per-language `lsp_config` field. This was deliberately refactored so c/cpp can share clangd config without duplication.

### LSP wiring uses the 0.11+ native API
`plugins/lsp/servers.lua` calls `vim.lsp.enable(name)` and `vim.lsp.config(name, opts)` directly. There is no `mason-lspconfig` (intentionally removed). Tool installation goes through `mason-tool-installer` which consumes `languages.get_mason_tools()` (LSP servers + formatters + linters + DAP binaries, deduped).

`languages.lua` carries a small `LSP_TO_MASON` table that translates lspconfig server names to mason package names where they differ (e.g. `bashls` → `bash-language-server`, `lua_ls` → `lua-language-server`, `yamlls` → `yaml-language-server`, `jsonls` → `json-lsp`). `get_mason_tools()` applies this translation before emitting the install list. Servers whose names match (gopls / clangd / pyright / ...) need no entry. This replaces what `mason-lspconfig` used to provide. When adding a new server whose mason name differs from its lspconfig name, add a single row to `LSP_TO_MASON`.

### `:Diagnostics` list UI is trouble.nvim, not quickfix/loclist
`plugins/lsp/diagnostics.lua`'s `:Diagnostics project/buffer` calls `require("trouble").open(...)`, NOT `vim.diagnostic.setqflist/setloclist`. The bare `:Diagnostics` (cursor-position) still uses `vim.diagnostic.open_float()`. If you remove trouble.nvim, restore the qflist/loclist branches in diagnostics.lua.

### Document highlight is native LSP, not a plugin
`plugins/lsp/highlight.lua` replaces vim-illuminate (which was deleted). It listens on `LspAttach` for `documentHighlightProvider` clients, registers per-buffer `CursorHold/CursorHoldI` + `CursorMoved` autocmds calling `vim.lsp.buf.document_highlight()` / `clear_references()`. Tied to `updatetime` (settings.lua: 100ms). Do not re-add vim-illuminate.

The same file overrides `LspReferenceText/Read/Write` to use `underdouble = true` with `sp = "#F8F8F2"` (no fg/bg). Reason: dracula's defaults render reference highlights as orange foreground, which clobbers the Tonsky color scheme. The override is wrapped in a `ColorScheme` autocmd so theme switches don't lose it. If you change to a different visual cue (background tint, undercurl, etc.), edit `set_lsp_reference_underline()` in this file.

### LazyDev injects nvim API library into lua_ls (lua filetype only)
`plugins/lsp/lazydev.lua` setup runs once globally; `plugins/lsp/completion.lua` puts `lazydev` first in `sources.per_filetype.lua`, never in `sources.default`. Other filetypes are unaffected. Do not promote lazydev to a global blink source.

### DAP is config-driven, not hard-coded
`plugins/tools/dap.lua` loops over `languages.get_dap_configs()` and dispatches:
- `helper = "dap-go"` → `require("dap-go").setup({})`
- `helper = "dap-python"` → `require("dap-python").setup(<mason debugpy venv path>)`
- `adapter = "codelldb"` (no helper) → manual `dap.adapters.codelldb` registration with shared `dap.configurations.{c,cpp}`

To add a new language's debugger, edit `languages.lua`'s `dap = { adapter, mason, helper? }`. Do **not** add per-language DAP config to `dap.lua`.

### Neotest is config-driven, not hard-coded
`plugins/tools/test.lua` collects vim.pack URLs from `languages.get_test_configs()` (default `https://github.com/nvim-neotest/<adapter>`, override via `cfg.src` for non-`nvim-neotest` orgs) and instantiates each via `require(cfg.adapter)(cfg.opts or {})` into the `adapters` table passed to `neotest.setup`. Currently only `neotest-go` is registered.

To add a language's test runner, edit `languages.lua`'s `test = { adapter, src?, opts? }`. Do **not** add per-language neotest config to `test.lua`.

### Tonsky highlights live in `config/highlights.lua`
Rules per https://tonsky.me/blog/syntax-highlighting/ , palette per Dracula. The full agreed-upon rule set is in `~/.claude/projects/-home-gcy--config-nvim/memory/user_highlight_rules.md` — read it before changing colors or category mappings. Color summary (Dracula × Tonsky):

| Role | Color | Dracula name |
|---|---|---|
| strings + numbers (merged) | `#50FA7B` | Green |
| comments | `#F1FA8C` | Yellow |
| all definition points (func / type / struct / const / var / x:= / parameters / fields) | `#8BE9FD` | Cyan |
| builtin constants only (`nil` / `true` / `false` / `NULL` / `nullptr` / `iota`) | `#BD93F9` | Purple |
| punctuation **and** all operators (`+ - * / == && || = :=` etc.) | `#7C89B6` | Comment lifted |
| everything else (keywords, variable uses, function calls, builtin types, user-defined constant uses) | `#F8F8F2` | Foreground |

No `bold` or `italic` attributes are set — Tonsky's anti-rule against extra styles. If you need to dim something further, route it to `@punctuation.*` or `@operator`; do not introduce a new color.

Implementation uses a **window-local highlight namespace** (`tonsky_highlights`), applied only to `go`/`c`/`cpp` via `nvim_win_set_hl_ns`. The `M.apply()` function defines all highlight groups, sets up `BufWinEnter`/`FileType`/`WinEnter` autocmds for the namespace switch, and is called by `treesitter.lua` on every `ColorScheme` event. Do not add hardcoded highlight overrides in `treesitter.lua` or other plugin files — all custom highlight logic goes here.

**Known limitation**: window-local namespaces don't reach `nvim-treesitter-context`'s sticky float (separate window id). The float falls back to dracula defaults.

Key anti-patterns the rules enforce: `@function.call`/`@function.method.call` are forced to base (function calls must not look like definitions), `@constant` (user-defined constant **uses**) goes to base, only `@constant.builtin` and `@boolean` go purple.

### Custom Treesitter queries live in `queries/<lang>/highlights.scm`
Per-language query files feed the Tonsky rules in `highlights.lua` by routing nodes to the right capture groups (`@function`, `@variable.definition`, `@constant.builtin`, `@operator`, `@punctuation.*`, …). Note: `queries/go/highlights.scm` does **not** use `;extends` (it fully replaces upstream go queries to keep precise control); the C/C++ files use `;extends`/`;inherits: c` to layer on top of upstream.

- `queries/go/highlights.scm` (~120 lines, **full replacement**) — function / method / interface-method definitions; `type_spec` + `type_alias`; `short_var_declaration` / `var_spec` / `const_spec` / `parameter_declaration` / `variadic_parameter_declaration` / `field_declaration` definition points; `package_clause` / `import_spec` aliases; `(true)` / `(false)` / `(nil)` and the `iota` identifier mapped to `@constant.builtin`; string + rune literals merged to `@string`; `=` and `:=` routed to `@punctuation.delimiter` so they pick up dim color; full operator list (`++` `--` `~` `&^` etc.) explicitly captured to `@operator`.
- `queries/c/highlights.scm` (~150 lines, `;extends`) — pointer-asterisk coloring (5 `#has-descendant?`/`#has-ancestor?` rules covering function returns, field decls, parameters, var decls, function declarations); `field_identifier` → `@variable.definition`; `=` overridden to `@punctuation.delimiter`; `NULL` / `true` / `false` identifier-matched to `@constant.builtin`; struct / union / enum tag → `@type`; enum members → `@variable.definition`; object-macros vs function-macros split (`preproc_def` vs `preproc_function_def`); goto labels; explicit operator list (`++` `--` `~` `?` `->` etc).
- `queries/cpp/highlights.scm` (~100 lines, `;inherits: c`) — `(null)` (the grammar's name for `nullptr`) → `@constant.builtin`; `class_specifier` → `@type`; `namespace_definition` → `@variable.definition`; `destructor_name` and `operator_name` → `@function`; template type/value parameters; `alias_declaration` (using = ...); lambda capture identifiers; structured-binding identifiers; reference-declarator `&` colored same as the bound name (mirroring C's pointer `*` rules).

### Custom TS predicates in `util/ts_predicates.lua`
Registers `#has-descendant?` predicate via `vim.treesitter.query.add_predicate`. Used in C queries to distinguish function declarations (have `function_declarator` descendant) from variable declarations in pointer asterisk coloring. Called by `treesitter.lua` at load time.

### Indent mode dispatch via `config/indent.lua`
Separated from `treesitter.lua` for focus. Reads `languages.get_langs_by_indent_mode()` and creates 4 `FileType` autocmd groups: cindent, smartindent, autoindent, treesitter. Called from `init.lua`.

### Theme is dracula only
`plugins/ui/theme.lua` loads dracula.nvim and sets `colorscheme dracula`. The dankcolors (matugen base16) theme was removed — if you want it back, revert git history. Do not call `vim.cmd.colorscheme()` directly elsewhere.

### Startup screen is a dynamic project picker, not a static menu
`plugins/ui/dashboard.lua` (mini.starter) generates the "Projects" section by scanning persistence.nvim's session directory at startup, decoding cwd from filename (`%home%user...%proj.vim` → `/home/user/.../proj`, with `%` ↔ `/`), and sorting by mtime. Selecting an entry runs `cd <path> | PersistenceLoad`. Other items live under "Other" (Find files / Recent / Live grep / Help / Choose session / Quit). Do not revert items to a static list — the dynamic generator is the point.

### Minuet ghost text is gated on `DEEPSEEK_API_KEY`
`plugins/tools/ai/minuet.lua` checks `vim.env.DEEPSEEK_API_KEY` at the top. If unset, it returns early — no `vim.pack.add`, no `setup()`, no keymaps — and only registers `:MinuetToggle` as a stub that throws a clear error message ("DEEPSEEK_API_KEY is not set..."). Reason: the upstream plugin crashes with `attempt to concatenate a nil value` (`'Bearer ' .. nil`) on the very first auto-trigger if no key is configured.

`plugins/lsp/completion.lua` mirrors the gate: blink's `sources.default` is `{ "lsp", "path", "snippets", "buffer", "minuet" }` only when the env var is set, otherwise the `"minuet"` entry is dropped so blink never tries to load `minuet.blink` against an un-setup'd plugin. After exporting the key, restart nvim — there is no live reload of either gate.

### Lazy loading via `lua/util/lazy.lua`
`plugins/init.lua` loads UI / LSP / editor / essential tools eagerly, but heavy command-driven plugins (`dap`, `sql`, `claudecode`, `toggleterm`, `grug-far`) go through `util.lazy.on_cmd` / `on_keys`. The lazy stub registers placeholder commands/keymaps that, on first invocation, delete all stubs, `require()` the real module, and replay the original input.

If you add a new heavy plugin, follow the same pattern. If you need to add eager loading instead, ensure it doesn't slow down startup significantly — `vim.loader.enable()` is on (init.lua line 1) so cached requires are cheap.

## User conventions (must follow)

The user prefers `:UserCommand` over keymaps. When adding a new feature:
1. Always register a `:UserCommand` with `desc` and `complete` (where applicable).
2. Only add a keymap if it is genuinely high-frequency (e.g. `<leader>de` for DAP eval). Most functionality should be reachable via `:` + Tab or `:FzfLua commands`.
3. Every `vim.keymap.set` call must include `desc`. This serves both which-key and grep-based discovery.
4. Update `README.md`'s "用户命令快查" / "快捷键" tables when adding commands or keymaps.

## Deployment

### Bootstrap script (`bootstrap.py`)

Python 3 script (stdlib only — `subprocess`, `concurrent.futures`, `pathlib`, `re`). No `pip install` needed.

- Extracts all `src = "https://github.com/..."` URLs from `lua/` and `init.lua` (regex, deduped, sorted)
- Parallel clone/update via `ThreadPoolExecutor` (default 8, `-j` to adjust):
  - Missing → `git clone --depth 1 --quiet`
  - Existing → `git fetch origin <branch>` + `git reset --hard origin/<branch>` (always to HEAD, no tag logic)
  - Broken (empty dir or only `.git` with no files) → `rmtree` + re-clone
  - `-f` → `rm -rf` + re-clone everything
- Output: `[N/T]` progress counter + colored ANSI symbols (`↓` cyan / `✓` green / `↻` blue / `✗` red), secondary info in gray. Colors auto-disable when piped.
- Retries missing/broken plugins (2 serial passes) after the parallel pass
- Section headers (`─── Plugins (N found, N parallel) ───`) between stages

**Post-clone phases** — each runs headless nvim, stdout filtered in real-time by Python:
- **blink.cmp**: native Rust fuzzy matcher build (up to 10 min). Only `[blink.cmp] ...` lines shown.
- **Mason**: LSP / formatter / DAP install (up to 20 min, 3 retries for failed packages). Only `[mason] ...` lines shown. Already-cached packages reported as one `N/T cached` line; newly installed packages shown as `N/T package-name` as they complete.

All other nvim output (treesitter messages, vim.pack progress, Mason internal "installing/successfully installed" notifications) is discarded via `subprocess.PIPE` line filtering. Stderr → `DEVNULL`.

The Lua install logic is embedded as Python string constants:
- `MASON_LUA` — `vim.wait`-based polling, `MasonToolsStartingInstall`/`MasonToolsUpdateCompleted` autocmds, 3 retries, per-package progress via `seen`-based diffing
- `BLINK_LUA` — calls `require("blink.cmp").build():wait(300000)`

**Bootstrap only catches literal `src = "https://github.com/..."` patterns.** Runtime-constructed URLs (e.g. neotest-go in `test.lua`) are missed and get cloned on first nvim startup via `vim.pack.add()`. The `nvim-pack-lock.json` file in the repo root persists plugin specs; `vim.pack.add()` syncs it at startup — deleting `~/.local/share/nvim` won't remove plugins still in the lock file. When removing a plugin, delete its entry from the lock file too.

### System dependencies

| Dependency | Which plugin needs it |
|---|---|
| `tree-sitter` CLI | nvim-treesitter (compile parsers locally) |
| Rust toolchain (`cargo`) | blink.cmp (fuzzy matcher), protols (optional) |
| `DEEPSEEK_API_KEY` env var | minuet-ai (ghost text via Deepseek API) |
| `claude` CLI | claudecode.nvim |

## Verifying changes

There is no traditional CI. Verification means:

```bash
# Single-file Lua syntax check (won't actually run plugins, just parse)
nvim --headless -c "lua local fn,err = loadfile('lua/path/to/file.lua'); print(fn and 'OK' or err)" -c qa

# Bulk syntax check (loop over all files)
for f in $(find lua init.lua -type f -name "*.lua"); do
  nvim --headless -c "lua local fn,err = loadfile('$f'); print('$f:', fn and 'OK' or err)" -c qa 2>&1 | grep -E "OK|error"
done

# Startup timing (needs a TTY — pipe through `script` to simulate one)
script -q -c 'nvim --startuptime /tmp/startup.log +q' /dev/null > /dev/null 2>&1
grep "NVIM STARTED" /tmp/startup.log

# Inside running nvim
:checkhealth                                          # everything
:lua require("config.languages").show_stats()         # config-center counts
:lua vim.pack.update()                                # update + clean stale packages
```

**Headless mode caveat**: `nvim --headless` may produce a lualine traceback because `vim.pack.add` doesn't fully populate runtimepath in non-TTY mode. This is cosmetic — interactive startup works. Bootstrap.sh prevents the actual empty-clone bug that previously caused the same symptom.

## Pointers

- `README.md` — full reference for user commands, keymaps, file structure, and how to add a language. Keep it in sync when changing public behavior.
- `~/.claude/projects/-home-gcy--config-nvim/memory/` — persistent notes about user preferences and refactor decisions. Read these if confused about why something is structured a certain way.
