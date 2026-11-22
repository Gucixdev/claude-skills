# ui (accents)

Sets of colours that go together, made with `tools/palette` (python3 stdlib, header = help). All maths is OKLCH
(Ottosson's OKLab, as CSS Color 4 defines it), so equal steps look equal, and a colour outside sRGB loses chroma, not
hue or lightness. The conversions are checked in `tests/palette.bats` against white = L 1, black = 0, the sRGB
primaries (red L 0.628 C 0.258 h 29.2) and ImageMagick.

## Commands

- `palette gen HEX [--scheme analogous|complementary|triadic|split|tetradic|mono] [--n N] [--json]` - N accents,
  `accent-1` is the seed, the rest rotate the hue (30, 180, 120, 150/210, 90 degrees) and keep chroma 0.06-0.20 and
  lightness 0.40-0.85. `mono` keeps the hue and walks lightness.
- `palette check FG BG [--json]` - WCAG 2.x ratio and AA/AAA for normal and large text; exit 1 below 4.5.
- `palette set HEX [--json]` - bg, surface, border, text, muted, accent, accent-hover, success, warning, danger for
  light (`:root`) and dark (`prefers-color-scheme`) as CSS custom properties. Each text colour is moved in lightness
  until it reaches 4.5:1 on both bg and surface, measured on the rounded hex; a pair that cannot is named on stderr
  and the exit code is 1.
- Exit codes: 0 ok, 1 contrast below AA, 2 bad input. Same input gives the same output.

## Rules of thumb

- One accent per screen; the rest of the palette is bg, surface, border and text tinted with the seed hue.
- Accent text and links need 4.5:1 (3:1 only for large text and for non-text parts like focus rings); never carry
  meaning by colour alone - pair success/warning/danger with an icon or a word.
- Check any hand-picked pair with `palette check`, do not eyeball it. The border is not text and is not checked.
- A grey seed has no hue; `gen` then rotates from hue 0 with a small chroma floor, pick a real seed for accents.
