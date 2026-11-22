---
name: ui
description: Interfaces and media - CLIs, TUIs and GUIs the way he likes them (lazytui, green on dark, bitmap fonts, springs), web at zero cost (static first, WASM), images, video, audio, fonts and 3D from the command line. Use for any interface, website or media conversion.
metadata:
  priority: "2"
  tags: "#thirdparties #ui #ux #tui #cli #design #animation #dev #webdev #web #html #css #wasm #typescript #media #images #video #audio #fonts #3d #imagemagick #ffmpeg #assimp"
  requires: "?cmd:fzf ?cmd:tmux ?font:fixed ?cmd:node ?cmd:clang ?cmd:morph ?cmd:magick|convert ?cmd:ffmpeg ?cmd:ffprobe ?cmd:fc-list ?cmd:fontforge ?cmd:assimp ?cmd:blender"
---

# ui

Pick the part by the surface.

<!-- digest -->

## Parts

Read the part when the task matches.

- [media-cli](references/media-cli.md) - Images, video, audio, fonts and 3D models from the command line - his morph and fixmedia tools first, then ImageMagick (magick or convert), ffmpeg and ffprobe (NVENC on his GTX 1050 Ti), fonts (fc-list, fontforge, fonttools, bitmap fonts, GNU FreeFont and OFL licensing) and assimp for model conversion to glTF for Godot. Use for any conversion, resize, transcode, trim, GIF, sprite sheet, font or model task.
- [webdev](references/webdev.md) - Web work at zero cost - static HTML and CSS first, native elements over libraries, JavaScript only where it earns its place, WASM for compute (his main web target), TypeScript only where JS falls short, free hosting, one static binary or Rails on the server, accessibility, no trackers, security headers, tests through his own browser. Use for websites, web apps, landing pages and browser-side code.
- [ui-designer](references/ui-designer.md) - Design CLIs, TUIs and UIs the way he likes them - CLI conventions (help from the header, data on stdout, exit codes, TSV), lazytui TUI techniques (key bar, space to mark, / to search, Tab between views, numbered fallback), green text on a dark background, bitmap fonts (misc-fixed 6x13, the TempleOS 8x8 look), Cassowary constraints with percentages for scaling, spring-damper differential equations for animation, and keeping the UI apart from the critical logic when that pays. Use for any interface, from a --help text to a GUI.
- [accents](references/accents.md) - Colour accents that go together - tools/palette makes N accents from a seed in OKLCH (analogous, complementary, triadic, split, tetradic, mono), checks WCAG contrast, and builds a full light and dark set as CSS custom properties with every text pair at AA. Use for palettes, theme colours, accent colours and contrast checks.
