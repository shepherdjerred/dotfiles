---
name: terminal-concepts
description: |
  This skill should be used when the user is building CLI or TUI applications, implementing argument parsing, handling terminal input/output, escape codes, buffering, signals, or asks about terminal development concepts. Provides comprehensive guidance on terminal internals, design principles, and battle-tested patterns.
version: 1.0.0
---

# Terminal Concepts for Developers

## Overview

This skill provides comprehensive guidance for **building and developing** terminal applications (CLI tools and TUIs). It covers how terminals work, design principles from proven programs, and practical patterns for creating robust, user-friendly command-line applications.

**Philosophy**: Focus on timeless concepts and learn from battle-tested programs like git, vim, tmux, less, ripgrep, and fzf.

**Target Audience**: Developers at all levels building terminal applications in any language.

## What Developers Need to Know

Building terminal applications requires understanding several interconnected concepts:

1. **Terminal Fundamentals**: How TTYs, PTYs, streams, and buffering work
2. **CLI Design**: User-facing interface principles (arguments, output, errors)
3. **TUI Architecture**: Interactive full-screen applications
4. **Common Pitfalls**: Issues developers face and how to avoid them

## Learning from Proven Programs

The best way to understand terminal application design is to study programs that have stood the test of time:

- **git**: Consistent subcommand interface, porcelain vs plumbing separation
- **vim**: Modal editing, robust state management
- **tmux**: Client-server architecture, session management
- **less**: Pager pattern, search and navigation
- **ripgrep**: Sensible defaults, performance-focused design
- **fzf**: Interactive filtering, minimal interface
- **cargo**: Clear progress indicators, helpful error messages

---

## Terminal Fundamentals

- Terminal emulators communicate with your program through PTYs (pseudo-terminals)
- **Cooked mode** (default): OS handles line editing, Ctrl-C sends SIGINT, input arrives line-by-line
- **Raw mode** (TUIs): Character-by-character input, your program handles everything
- Three standard streams: stdin (fd 0), stdout (fd 1), stderr (fd 2) -- separate them properly
- Always detect TTY vs pipe with `isatty()` to decide colors, progress bars, formatting
- Only 33 Ctrl key combinations exist; Ctrl-Shift-X is not a distinct character in terminals

## CLI Design Principles

- **Human-first**: Show feedback, confirm danger, provide helpful errors
- **Composable**: stdout for results, stderr for diagnostics, meaningful exit codes
- **Consistent**: Use standard flags (-h, --help, -v, --verbose, -q, --quiet, --version)
- **Discoverable**: Suggest typo corrections, show examples in help, provide --dry-run
- Support POSIX and GNU flag styles; prefer flags over positional args for complex tools
- Three danger levels for confirmations: low (no prompt), medium (y/N), high (type-to-confirm)
- Always provide --force and --no-input for CI/CD scripting
- Configuration precedence: flags > env vars > local config > user config > system config > defaults
- Follow XDG Base Directory spec for config/data/cache paths

## Output and Error Handling

- Respect NO_COLOR env var; provide --color=always/never/auto
- Stick to 16 ANSI colors for maximum compatibility; detect 256/RGB support before using them
- Provide --json flag for machine-readable output (JSONL for streaming)
- Progress indicators on stderr, only for TTY, hidden in --quiet and CI
- Auto-page long output through $PAGER when in TTY
- Error messages: say what went wrong, suggest how to fix it, no stack traces by default
- Exit codes: 0 success, 1 general error, 2 invalid args, 130 for Ctrl-C (128+SIGINT)

## Escape Codes and Input

- Output codes (ECMA-48 CSI/OSC) control cursor, colors, screen clearing
- Input codes: arrow keys, function keys arrive as multi-byte ESC sequences
- Distinguish ESC key from escape sequences with timeout-based parsing (~50ms)
- Mouse events via ESC[?1000h/1002h/1006h; always disable on exit
- Most modern programs hardcode common ANSI sequences rather than querying terminfo

## Buffering

- TTY stdout: line-buffered; pipe stdout: block-buffered (~8KB); stderr: unbuffered
- The pipe buffering problem causes tools to appear frozen in pipelines
- Solutions: add --line-buffered flag, flush after important output, use stdbuf/unbuffer externally
- Always test your tool's output behavior in pipes

## TUI Development

- Respect conventions: 'q' quits, Ctrl-C exits/interrupts, ESC goes back, Ctrl-L redraws
- Implement readline keybindings (Ctrl-A/E/K/U/W) in line editors
- Use alternate screen buffer for full-screen TUIs; restore terminal state on exit (including crashes)
- Event loop patterns: blocking (simple), timeout-based (real-time), select-based (Unix)
- Double-buffer rendering to avoid flicker; diff-based updates for performance
- Handle SIGWINCH for terminal resize; handle SIGINT for graceful shutdown
- Multi-Ctrl-C pattern: first = graceful shutdown, second = force exit

## What's New

Terminal fundamentals are remarkably stable, but notable modern developments include:

- **Kitty graphics protocol**: Inline image display in supporting terminals (Kitty, Ghostty, WezTerm)
- **Ghostty**: New high-performance terminal emulator with native platform integration
- **Sixel graphics**: Older but increasingly re-adopted standard for inline images
- **OSC 52 clipboard**: Cross-terminal clipboard access gaining wider support (works over SSH)
- **Kitty keyboard protocol**: Extended key reporting solving modifier key limitations
- **Synchronized output** (DEC mode 2026): Eliminates flicker without manual double-buffering
- **Charm tools** (Bubble Tea, Lip Gloss, VHS): Modern Go TUI ecosystem
- **Ratatui**: Rust TUI framework (successor to tui-rs)
- **Ink**: React-based terminal UI framework for Node.js
- **Windows Terminal**: Full ANSI/VT support on Windows, ConPTY replacing legacy console

## When to Ask for Help

Ask the user for clarification or direction when dealing with:

- **Complex TUI state management**: Deep widget trees, focus across panels, undo/redo
- **Platform-specific behavior**: Windows Console API, legacy terminal types, cross-platform PTY
- **Performance optimization**: Large TUI rendering bottlenecks, streaming data memory usage
- **Custom escape sequences**: Features beyond standard sequences, runtime capability detection
- **Testing strategies**: Mocking complex terminal interactions, TUI testing in CI
- **Architecture decisions**: CLI vs TUI, client-server for terminal apps, plugin systems
- **Security**: Handling sensitive input, command injection prevention, clipboard security
- **Accessibility**: Screen reader compatibility, high contrast, keyboard-only navigation
- **Advanced topics**: Language servers (LSP), REPL implementation, terminal multiplexer design

## Top 10 Design Principles

1. **Detect TTY, format appropriately** -- colors/progress for humans, plain for pipes
2. **Separate stdout and stderr** -- results vs diagnostics enables composability
3. **Handle buffering correctly** -- add --line-buffered, flush after important output
4. **Use standard flag names** -- -h, --help, --version, -v, -q; users have muscle memory
5. **Provide excellent error messages** -- what went wrong + how to fix it
6. **Exit with meaningful codes** -- 0 success, non-zero errors, document specific codes
7. **Handle signals gracefully** -- Ctrl-C always works, clean up terminal state
8. **Support non-interactive mode** -- --no-input and --force for CI/CD
9. **Respect user environment** -- NO_COLOR, EDITOR, PAGER, XDG directories
10. **Test with real terminals** -- different emulators, sizes, pipes, and redirects

## Common Mistakes to Avoid

- Ignoring isatty() -- always check before colors/progress
- Stack traces for users -- hide by default, show with --debug
- Secrets in flags -- use files or prompts instead
- Hanging without feedback -- show progress or spinner
- Forgetting to flush -- buffering causes pipes to hang
- Hardcoding RGB colors -- use 16 ANSI colors for compatibility
- Ignoring SIGINT -- users expect Ctrl-C to work
- Not restoring terminal state -- crashes leave broken terminal
- Inconsistent flag names -- follow standards
- Poor help text -- include examples

---

## Additional Resources

Detailed reference files are available for deep dives into specific topics. Load these when you need implementation details beyond what this overview provides.

- **`references/terminal-fundamentals.md`** -- Load when working with TTYs, PTYs, terminal modes, standard streams, or TTY detection. Covers the terminal stack, cooked vs raw mode, and isatty() implementations in C, Rust, Python, and Go.

- **`references/control-characters.md`** -- Load when designing keyboard shortcuts or handling control character input. Covers all 33 control characters, the three categories (OS-handled, keyboard literals, application-specific), and modifier combination limitations.

- **`references/escape-codes.md`** -- Load when implementing colors, cursor movement, mouse support, or terminal capability detection. Full ANSI/CSI/OSC/private sequence reference, input escape sequences, terminfo concepts, and capability detection patterns.

- **`references/buffering.md`** -- Load when debugging pipe buffering issues or implementing streaming output. Covers the three buffering modes, the 8KB threshold problem, solutions in multiple languages, and testing strategies.

- **`references/cli-design.md`** -- Load when designing a CLI tool's interface, argument parsing, help text, configuration management, or interactive features. Comprehensive coverage of the 9 core principles, POSIX/GNU conventions, subcommand patterns, progress indicators, XDG directories, and project layout.

- **`references/output-and-errors.md`** -- Load when implementing color output, JSON mode, progress indicators, pager integration, error messages, exit codes, signal handling, or terminal state management. Includes environment variable reference and signal reference tables.

- **`references/tui-development.md`** -- Load when building a full-screen TUI application. Covers raw mode, event loops, input handling, rendering strategies (alternate screen, double buffering, diff-based), layout management, focus, scrolling, cross-platform issues, performance, testing, and build/distribution.
