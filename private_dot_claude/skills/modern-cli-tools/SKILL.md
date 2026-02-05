---
name: modern-cli-tools
description: |
  This skill should be used when the user mentions fd, rg, eza, bat, or asks about faster
  CLI alternatives, or when about to use legacy tools (find, grep, ls, cat, sed, du, df, ps).
  Provides guidance for modern Unix command alternatives that are faster and more user-friendly.
version: 1.0.0
---

# Modern CLI Tools Agent

## What's New in 2025

- **eza Replaces exa**: Original exa is unmaintained (@ogham unreachable), use **eza** fork instead
- **eza v0.23.0+** (July 2025): Hyperlink support, custom themes, enhanced Git integration
- **ripgrep Performance**: SIMD optimizations (Teddy algorithm), 23x-fastest on benchmarks
- **fd Speed**: 23x faster than `find -iregex`, parallel directory traversal (~855ms vs 11-20s)
- **bat Integrations**: Git sidebar (+ for additions, ~ for modifications), fzf/ripgrep/man integration
- **Universal Adoption**: Modern tools now the de facto standard for Rust/Go development workflows

## Overview

This agent teaches modern alternatives to traditional Unix commands that are faster, more user-friendly, and feature-rich. These tools are written in Rust and other modern languages, providing significant performance improvements and better default behaviors.

**Important Note**: Always use **eza**, not exa. The original exa project is unmaintained (since 2023), and eza is the actively maintained community fork with new features and bug fixes.

## For Claude: Tool Selection Guidelines

**When performing file operations, ALWAYS prefer modern tools:**

- `find` -> `fd` - Faster, simpler syntax, respects .gitignore
- `grep -r` -> `rg` - 10-100x faster, better defaults
- `ls -la` -> `eza -la` - Better formatting, git integration
- `cat file` -> `bat file` - Syntax highlighting, line numbers
- `sed` -> `sd` - Simpler syntax, safer
- `du -sh` -> `dust` - Visual tree, faster
- `df -h` -> `duf` - Better formatting
- `ps aux` -> `procs` - Modern output, better filtering

**Before using legacy tools, check if modern alternatives are available.**

## Tool Comparison

| Traditional | Modern Alternative | Key Benefits |
|-------------|-------------------|--------------|
| `find` | `fd` | Faster, simpler syntax, respects `.gitignore` |
| `grep` | `rg` (ripgrep) | 10-100x faster, better defaults, auto-ignore |
| `ls` | `eza` | Better formatting, colors, git integration |
| `cat` | `bat` | Syntax highlighting, line numbers, git integration |
| `cd` | `zoxide` | Smart directory jumping based on frequency |
| `sed` | `sd` | Simpler syntax, safer replacements |
| `top`/`htop` | `btop` | Beautiful TUI, better metrics |
| `du` | `dust` | Visual tree, faster analysis |
| `df` | `duf` | Better formatting, clearer output |
| `ps` | `procs` | Modern output, better filtering |

## Installation

### macOS (Homebrew)
```bash
# Install all at once
brew install fd ripgrep eza bat fzf sd zoxide dust duf procs btop

# Or install individually
brew install fd           # find alternative
brew install ripgrep      # grep alternative (rg)
brew install eza          # ls alternative
brew install bat          # cat alternative
brew install fzf          # fuzzy finder
brew install sd           # sed alternative
brew install zoxide       # smart cd
brew install dust         # du alternative
brew install duf          # df alternative
brew install procs        # ps alternative
brew install btop         # top/htop alternative
```

### Linux (cargo - Rust package manager)
```bash
# Install Rust first
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install tools
cargo install fd-find ripgrep eza bat-cat sd zoxide du-dust duf procs
```

## Tool Summaries

**fd** is a fast, user-friendly alternative to `find`. It uses smart case-insensitive matching by default, respects `.gitignore`, supports regex, and runs searches in parallel for dramatically faster results (up to 23x faster than `find`). See `references/fd-rg-guide.md` for full usage.

**rg (ripgrep)** is a blazing-fast grep replacement that recursively searches directories while respecting `.gitignore`. It features SIMD-optimized string matching, automatic file type detection, and sensible defaults that make it 10-100x faster than traditional grep. See `references/fd-rg-guide.md` for full usage.

**eza** is the actively maintained community fork of the now-abandoned exa project. It provides beautiful, colorized directory listings with git integration, tree views, icons (via Nerd Fonts), and hyperlink support in v0.23.0+. See `references/eza-bat-guide.md` for full usage.

**bat** is a `cat` replacement with syntax highlighting for over 100 languages, automatic paging, line numbers, and git change indicators in the sidebar. It integrates well with fzf, ripgrep, and man pages. See `references/eza-bat-guide.md` for full usage.

**fzf** is a general-purpose fuzzy finder that can filter any list interactively -- files, command history, git branches, processes, and more. It pairs powerfully with fd and bat for preview-enabled file selection. See `references/fzf-zoxide-sd.md` for full usage.

**zoxide** is a smarter `cd` that learns most-visited directories and enables jumping to them with partial name matches. After visiting a directory once, `z partial-name` gets there instantly. See `references/fzf-zoxide-sd.md` for full usage.

**sd** is a simpler, safer alternative to `sed` for find-and-replace operations. It uses straightforward string/regex syntax without the need for escaping delimiters, making bulk text replacements across files intuitive. See `references/fzf-zoxide-sd.md` for full usage.

## When to Ask for Help

Ask the user for clarification when:
- Unsure which tool is best for their specific use case
- Need to perform complex regex transformations
- Working with very large files (>1GB)
- Custom configuration needed for their workflow
- Integration with existing scripts or tools
- Performance optimization for specific scenarios

## Additional Resources

Detailed usage guides, advanced examples, and configuration references are in the `references/` directory:

- **`references/fd-rg-guide.md`** - Complete fd and ripgrep usage: basic commands, advanced patterns, regex, common use cases
- **`references/eza-bat-guide.md`** - Complete eza and bat usage: listing options, tree views, syntax highlighting, git integration, tool integration
- **`references/fzf-zoxide-sd.md`** - Complete fzf, zoxide, and sd usage: fuzzy finding, smart cd, find-and-replace
- **`references/migration-guide.md`** - Combining tools into workflows, alias suggestions, performance benchmarks, best practices, configuration files, troubleshooting, and migration from legacy commands
