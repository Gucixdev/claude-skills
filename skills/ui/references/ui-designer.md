# ui (ui-designer)

## CLI

- `-h`/`--help` prints the header comment; usage lines first, then one example. `--` ends options.
- Data on stdout (TSV, one record per line, stable column order), messages and errors on stderr, one line each with
  the fix ("fzf is missing (pacman -S fzf)").
- Exit 0 fine, 1 failed or found nothing, 2 bad usage. Idempotent where it can be; `-n` dry run for anything that
  changes things; `-f` to overwrite; `-q` quiet.
- Colour only on a terminal and never when `NO_COLOR` is set; nothing depends on colour alone. Static colourful
  output in his C tools goes through `colorado` (a stdin colourizer), not hardcoded escapes - real TUIs excepted.
- Subcommands are verbs (`list`, `install`, `remove`); no arguments on an interactive tool opens the TUI.

## Which toolkit (his decision 2026-11-24)

lazyUI-rs (Gucixdev/lazyUI-rs) is the UI standard everywhere: native window, terminal, CLI and web, also CRUD and SaaS
apps. Every Rust GUI (filem8, steamdeck_launcher, ...) and web product (fastkit) uses it. lazytui-c is the TUI toolkit for
programs written in C: it grows too, but stays lighter than the Rust one (TUI only, minimal).

## TUI (lazytui)

His `lib/lazytui` (fzf-based, in Gucixdev/bash) and the C library `lazyui/tui` set the conventions:
- A key bar always visible, each key drawn as a cap (Ctrl blue, Alt yellow, Shift green, the key reverse video) next
  to its label - nnn's look. Every action reachable from the keyboard and shown in the bar.
- Arrows or Tab to move, Space marks rows like nnn, `/` searches, Tab switches views, Enter opens, Esc or q goes back.
  The same keys in every tool.
- Rows come from a command that prints TSV; the view refreshes by re-running it (`reload`), keeping the cursor on its
  row (`--id-nth` in fzf 0.71+). Preview pane for the selected row.
- Degrade: no fzf or too old - a numbered list with `read`; no terminal - the plain commands.
- Mouse: click, double click, wheel, drag on scrollbars in the C library; never required.
- Redraw only what changed: a diff renderer writes only changed cells; redraw on dirty or animating, not on a timer;
  a scheduler (priority queue) for timed updates.
- Test it for real: tmux `send-keys` and `capture-pane`, or a pty with a set window size (`code (done)`).

## Look

- Default: green text on a dark background (his `matrix` theme is the default in the C library; a phosphor terminal).
  Other themes from a registry, each with a gradient used by graphs and progress bars; `temple` is white background
  with blue text (TempleOS).
- Fonts: bitmap. misc-fixed 6x13 (`fixed` in xorg-fonts-misc, PCF/BDF; for a Wayland terminal convert to OpenType
  bitmap: `fonttosfnt -o 6x13.otb 6x13.bdf`) and the TempleOS 8x8 look (community recreations; check each one's
  license before bundling). Integer scaling only, no antialiasing, no fractional sizes.
- Box drawing and block glyphs for frames and charts; half blocks for double vertical resolution; braille for line
  charts; an ASCII fallback on the Linux console.

## One palette for every app

A theme is one palette file (`colors.toml`: background, foreground, accent, the 16 terminal colours); a `theme-set`
renders templates from it into each app's config (terminal, Emacs, bar, lazytui, Hyprland) in a staging folder, then
swaps the staging folder in with one `mv`, so a switch never leaves half the apps on the old colours. That is how
omarchy does it; its `hackerman` theme is a ready green-on-dark palette (MIT).

## Layout: constraints and percentages

Describe layout as constraints and let a solver place things, so it scales with the window: Cassowary (his C library
has a kiwi-style solver), the same idea as ratatui's `Percentage`/`Min`/`Max`/`Length`/`Fill`.
- `sidebar.w == 0.25 * screen.w` (strong), `sidebar.w >= 20` (required), `sidebar.w <= 60` (strong), `main.x ==
  sidebar.x + sidebar.w`, `main.x + main.w == screen.w` (required).
- Required for what must hold, strong for intent, weak for preferences; re-solve on resize (SIGWINCH).
- In bash a percentage with clamps is enough: `w=$(( cols * 25 / 100 )); (( w < 20 )) && w=20`.

## Motion: differential equations

Animate by simulating, not by keyframes - interruptible, natural, frame-rate independent.
- Spring-damper toward a target: `a = -k (x - target) - c v`, then `v += a dt; x += v dt` (semi-implicit Euler) or
  RK4 for stiff springs (the C library uses RK4). Critical damping `c = 2 sqrt(k)` (unit mass) settles fastest with no
  overshoot - his "firm" preset; lower `c` bounces.
- Fixed timestep with an accumulator for determinism; stop when `|x - target|` and `|v|` are under a small epsilon.
- Simple easing without state: `x += (target - x) * (1 - exp(-lambda * dt))` - the same result at any frame rate.
- A new target mid-flight keeps the current velocity: no jumps. Respect a reduced-motion setting.

## UI apart from critical logic, when it pays

The logic is a command or a library with data in and data out, testable without a screen (his C library's `lt_app`:
spec text + model + handlers, headless-testable); the UI only calls it and draws. The UI never holds state that
matters; a crash in the UI loses no data. A 50-line script doesn't need the split (`code (ponytail)`); a manager that changes
the system, a long-running tool, or anything with a second front end (CLI + TUI + MCP) does.
