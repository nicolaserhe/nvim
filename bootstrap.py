#!/usr/bin/env python3
"""
bootstrap.py — 并行克隆/更新所有 vim.pack 插件 + blink.cmp 构建 + Mason 安装。

用法:
  ./bootstrap.py                默认 8 路并行
  ./bootstrap.py -j 16          调整并行数
  ./bootstrap.py -f             强制重新克隆全部
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

# ═══════════════════════════════════════════════════════════════
# 路径
# ═══════════════════════════════════════════════════════════════

CONFIG_DIR = Path(__file__).parent.resolve()
PACK_DIR = Path(
    os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share")
) / "nvim" / "site" / "pack" / "core" / "opt"

# ═══════════════════════════════════════════════════════════════
# 终端样式 (ANSI, 无外部依赖)
# ═══════════════════════════════════════════════════════════════

_USE_COLOR = sys.stdout.isatty()


def _esc(code: str, text: str) -> str:
    return f"{code}{text}\033[0m" if _USE_COLOR else text


def green(s: str) -> str:
    return _esc("\033[32m", s)


def red(s: str) -> str:
    return _esc("\033[31m", s)


def yellow(s: str) -> str:
    return _esc("\033[33m", s)


def cyan(s: str) -> str:
    return _esc("\033[36m", s)


def blue(s: str) -> str:
    return _esc("\033[34m", s)


def gray(s: str) -> str:
    return _esc("\033[90m", s)


def bold(s: str) -> str:
    return _esc("\033[1m", s)


def _term_width() -> int:
    try:
        return shutil.get_terminal_size().columns
    except Exception:
        return 80


def section(title: str) -> None:
    """打印居中分隔标题."""
    w = _term_width()
    line = "─" * w
    # 用 dim 色打印整行，标题加粗居中
    prefix = "── "
    suffix = " "
    pad = max(0, w - len(prefix) - len(title) - len(suffix))
    print(f"\n{gray(prefix + title + suffix + '─' * pad)}", flush=True)


# ═══════════════════════════════════════════════════════════════
# 线程安全输出 + 进度计数
# ═══════════════════════════════════════════════════════════════

_print_lock = threading.Lock()
_status_counts: dict[str, int] = {}
_plugin_total = 0


def print_status(symbol: str, name: str, detail: str = "") -> None:
    """线程安全的状态行：符号 name detail，带等宽进度前缀."""
    global _status_counts
    with _print_lock:
        _status_counts[symbol] = _status_counts.get(symbol, 0) + 1
        done = sum(_status_counts.values())
        if _plugin_total > 0:
            w = len(str(_plugin_total))
            prefix = gray(f"[{done:>{w}}/{_plugin_total}]")
        else:
            prefix = ""
        if detail:
            print(f" {prefix} {symbol} {name} {gray(detail)}", flush=True)
        else:
            print(f" {prefix} {symbol} {name}", flush=True)


# ═══════════════════════════════════════════════════════════════
# URL 提取
# ═══════════════════════════════════════════════════════════════

_SRC_PAT = re.compile(r'src\s*=\s*"(https://github\.com/[^"]+)"')


def extract_urls() -> dict[str, None]:
    """从 lua/ 和 init.lua 提取所有 vim.pack src URL（去重、排序）."""
    urls: dict[str, None] = {}

    lua_files = list(CONFIG_DIR.rglob("*.lua"))
    init_file = CONFIG_DIR / "init.lua"
    if init_file.exists():
        lua_files.append(init_file)

    for f in lua_files:
        try:
            text = f.read_text()
        except Exception:
            continue
        for m in _SRC_PAT.finditer(text):
            url = m.group(1)
            if url not in urls:
                urls[url] = None

    return dict(sorted(urls.items()))


# ═══════════════════════════════════════════════════════════════
# Git 操作
# ═══════════════════════════════════════════════════════════════


def _git_current_ref(dest: Path) -> str:
    """HEAD 简短描述: tag 名 或 commit hash."""
    r = subprocess.run(
        ["git", "describe", "--tags", "--exact-match", "HEAD"],
        cwd=dest, capture_output=True, text=True,
    )
    if r.returncode == 0:
        return r.stdout.strip()
    r = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        cwd=dest, capture_output=True, text=True,
    )
    return r.stdout.strip() if r.returncode == 0 else "???"


def _git_default_branch(dest: Path) -> str:
    """探测默认分支名."""
    for cmd in (
        ["git", "symbolic-ref", "--short", "HEAD"],
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
    ):
        r = subprocess.run(cmd, cwd=dest, capture_output=True, text=True)
        branch = r.stdout.strip()
        if branch and branch != "HEAD":
            return branch

    r = subprocess.run(
        ["git", "remote", "show", "origin"],
        cwd=dest, capture_output=True, text=True, timeout=10,
    )
    m = re.search(r"HEAD branch:\s*(\S+)", r.stdout)
    return m.group(1) if m else "main"


def _clone_new(url: str, name: str, dest: Path) -> bool:
    """全新克隆."""
    try:
        r = subprocess.run(
            ["git", "clone", "--depth", "1", "--quiet", url, str(dest)],
            capture_output=True, timeout=300,
        )
        if r.returncode != 0:
            print_status(red("✗"), f"FAILED: {name}")
            shutil.rmtree(dest, ignore_errors=True)
            return False
    except Exception:
        print_status(red("✗"), f"FAILED: {name}")
        shutil.rmtree(dest, ignore_errors=True)
        return False

    print_status(cyan("↓"), name)
    return True


def _update_existing(dest: Path, name: str) -> bool:
    """更新已存在的仓库: fetch + hard reset 到默认分支 HEAD."""
    branch = _git_default_branch(dest)
    before = _git_current_ref(dest)

    try:
        r = subprocess.run(
            ["git", "fetch", "origin", branch],
            cwd=dest, capture_output=True, text=True, timeout=120,
        )
        if r.returncode != 0:
            print_status(red("✗"), f"{name}: fetch failed, keeping {before}")
            return True
    except Exception:
        print_status(red("✗"), f"{name}: fetch failed, keeping {before}")
        return True

    try:
        r = subprocess.run(
            ["git", "reset", "--hard", "--quiet", f"origin/{branch}"],
            cwd=dest, capture_output=True, timeout=30,
        )
        if r.returncode != 0:
            print_status(red("✗"), f"{name}: reset failed")
            return False
    except Exception:
        print_status(red("✗"), f"{name}: reset failed")
        return False

    after = _git_current_ref(dest)
    if before == after:
        print_status(green("✓"), name, f"({after})")
    else:
        print_status(blue("↻"), name, f"{before} → {after}")
    return True


def clone_or_update(url: str) -> tuple[bool, str]:
    """克隆或更新单个插件。返回 (ok, name)."""
    name = url.rstrip("/").split("/")[-1].removesuffix(".git")
    dest = PACK_DIR / name

    global FORCE
    if FORCE and dest.exists():
        shutil.rmtree(dest, ignore_errors=True)

    if (dest / ".git").is_dir():
        has_files = any(p.name != ".git" for p in dest.iterdir())
        if has_files:
            return _update_existing(dest, name), name
        shutil.rmtree(dest, ignore_errors=True)

    return _clone_new(url, name, dest), name


# ═══════════════════════════════════════════════════════════════
# nvim headless 调用
# ═══════════════════════════════════════════════════════════════


def run_nvim(tag: str, lua_code: str, timeout_sec: int = 1200) -> None:
    """headless nvim 跑 Lua，只把 [tag]... 行过滤显示."""
    cmd = [
        "stdbuf", "-oL", "nvim", "--headless",
        "-c", f"lua {lua_code}",
        "-c", "qa",
    ]

    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )

    marker = f"[{tag}]"
    try:
        for line in proc.stdout:
            idx = line.find(marker)
            if idx >= 0:
                content = line[idx + len(marker):].strip()
                print(f"  {bold(f'[{tag}]')} {content}", flush=True)
    finally:
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()


# ═══════════════════════════════════════════════════════════════
# 内嵌 Lua 代码
# ═══════════════════════════════════════════════════════════════

MASON_LUA = r"""
local MAX_RETRIES = 3

local function install_once(tools, timeout_ms)
    local registry = require("mason-registry")
    local total = #tools
    local seen = {}

    local function count_installed()
        local n = 0
        for _, name in ipairs(tools) do
            if registry.has_package(name) then
                local ok, pkg = pcall(registry.get_package, name)
                if ok and pkg:is_installed() then
                    n = n + 1
                    seen[name] = true
                end
            end
        end
        return n
    end

    local function poll_installed()
        local n = 0
        local fresh = {}
        for _, name in ipairs(tools) do
            if registry.has_package(name) then
                local ok, pkg = pcall(registry.get_package, name)
                if ok and pkg:is_installed() then
                    n = n + 1
                    if not seen[name] then
                        seen[name] = true
                        table.insert(fresh, name)
                    end
                end
            end
        end
        return n, fresh
    end

    local pre_n = count_installed()
    if pre_n > 0 then
        io.write(string.format("[mason] %d/%d cached\n", pre_n, total))
        io.flush()
    end

    local stage = "refresh"
    local done = false

    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall", once = true,
        callback = function() stage = "install" end,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted", once = true,
        callback = function() done = true end,
    })

    require("mason-tool-installer").check_install(false, false)

    local last_n = pre_n
    vim.wait(timeout_ms, function()
        if done then return true end
        if stage == "install" then
            local n, fresh = poll_installed()
            if n > last_n then
                last_n = n
                io.write(string.format("[mason] %d/%d %s\n", n, total, table.concat(fresh, ", ")))
                io.flush()
            end
        end
        return false
    end, 500)

    return count_installed()
end

local languages = require("config.languages")
local tools = languages.get_mason_tools()
local total = #tools
local timeout_ms = 1200000

local start = vim.uv.hrtime()
io.write(string.format("[mason] installing %d packages...\n", total))
io.flush()

local n = install_once(tools, timeout_ms)

for retry = 1, MAX_RETRIES do
    if n >= total then break end
    io.write(string.format("[mason] retry %d/%d (%d missing)...\n", retry, MAX_RETRIES, total - n))
    io.flush()
    n = install_once(tools, timeout_ms)
end

local elapsed_s = math.floor((vim.uv.hrtime() - start) / 1e9)
if n >= total then
    io.write(string.format("[mason] done: %d/%d (%dm%02ds)\n", n, total, elapsed_s / 60, elapsed_s % 60))
else
    io.write(string.format("[mason] %d/%d (%dm%02ds) -- %d failed. Retry in nvim: :MasonToolsInstall\n",
        n, total, elapsed_s / 60, elapsed_s % 60, total - n))
end
io.flush()
"""

BLINK_LUA = r"""
local start = vim.uv.hrtime()
io.write("[blink.cmp] starting Rust fuzzy matcher build (cargo)...\n")
io.flush()

local ok, err = pcall(function() require("blink.cmp").build():wait(300000) end)

local elapsed = math.floor((vim.uv.hrtime() - start) / 1e9)
if ok then
    io.write(string.format("[blink.cmp] native ready (%dm%02ds)\n", elapsed / 60, elapsed % 60))
else
    io.write("[blink.cmp] build skipped, Lua fallback: " .. tostring(err) .. "\n")
end
io.flush()
"""

# ═══════════════════════════════════════════════════════════════
# 主流程
# ═══════════════════════════════════════════════════════════════

FORCE = False


def _dir_has_git(p: Path) -> bool:
    """目录存在且包含 .git."""
    return (p / ".git").is_dir() and any(x.name != ".git" for x in p.iterdir())


def main() -> None:
    global FORCE, _plugin_total

    parser = argparse.ArgumentParser(description="bootstrap Neovim plugins + Mason tools")
    parser.add_argument("-j", "--jobs", type=int, default=8)
    parser.add_argument("-f", "--force", action="store_true")
    args = parser.parse_args()

    FORCE = args.force
    PACK_DIR.mkdir(parents=True, exist_ok=True)

    # ── 依赖检查 ──────────────────────────────────────
    if not shutil.which("tree-sitter"):
        print(f" {yellow('⚠')} tree-sitter CLI not found (nvim-treesitter needs it)")
        print(f"   {gray('Arch: sudo pacman -S tree-sitter-cli')}")
        print()

    # ── 提取 URL ─────────────────────────────────────
    urls = extract_urls()
    _plugin_total = len(urls)

    if _plugin_total == 0:
        print("No vim.pack URLs found in lua/ or init.lua", file=sys.stderr)
        sys.exit(1)

    section(f"Plugins ({_plugin_total} found, {args.jobs} parallel)")
    force_note = gray(" --force") if FORCE else ""
    print(f" Syncing to {PACK_DIR}{force_note}")
    print()

    # ── 并行克隆/更新 ────────────────────────────────
    _status_counts.clear()

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(clone_or_update, url): url for url in urls}
        for future in as_completed(futures):
            try:
                future.result()
            except Exception:
                pass

    # ── 重试缺失 ─────────────────────────────────────
    for retry_pass in range(1, 3):
        missing = [url for url in urls if not _dir_has_git(PACK_DIR / url.rstrip("/").split("/")[-1].removesuffix(".git"))]
        if not missing:
            break

        print()
        print(f" Retry pass {retry_pass}: {len(missing)} missing (serial)...")
        for url in missing:
            clone_or_update(url)

    # ── 统计 ─────────────────────────────────────────
    present = sum(1 for p in PACK_DIR.iterdir() if _dir_has_git(p))
    section("Result")

    if present == _plugin_total:
        print(f" {green('✓')} All {present} plugins ready")
    else:
        print(f" {yellow('⚠')} {present}/{_plugin_total} plugins ready ({_plugin_total - present} failed)")

    print()

    # ── blink.cmp 构建 ───────────────────────────────
    if _dir_has_git(PACK_DIR / "blink.cmp"):
        section("blink.cmp")
        print()
        run_nvim("blink.cmp", BLINK_LUA, timeout_sec=600)

    # ── Mason 安装 ───────────────────────────────────
    if _dir_has_git(PACK_DIR / "mason.nvim"):
        section("Mason")
        print(f" {gray('fresh install may take 10+ min')}")
        print()
        run_nvim("mason", MASON_LUA, timeout_sec=1800)

    print()
    print(f" {bold('Run:')} nvim")
    print()


if __name__ == "__main__":
    main()
