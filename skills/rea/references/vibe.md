# rea (vibe)

"Make it feel like X" gets the same treatment as a file format: measure, write the numbers down, rebuild from the
numbers, compare reference and rebuild side by side (`verify`). The result is a feel spec, not an impression.

- Look: from the source first - CSS custom properties and computed styles, the theme or `.Xresources` file, the font
  file (`fc-scan FILE`, `fc-match -f '%{family}\n' NAME`, `pdffonts` for a PDF). Pixels only when there is no source:
  the palette with `convert SHOT.png -format %c histogram:info:- | sort -rn | head` (`magick` on ImageMagick 7),
  sizes and spacing measured on a screenshot taken at 100% scale.
- Motion: record it (`verify` has the Wayland capture), frames out with `ffmpeg -i rec.mp4 -vf fps=60 re/f%04d.png`,
  the moving thing's box per frame with `convert F -fuzz 10% -fill black +opaque '#RRGGBB' -format '%@\n' info:`
  (prints WxH+X+Y), position against time (frame number / fps; `ffprobe` gives the real frame rate). From the curve:
  duration, easing, overshoot. As a spring (`ui (ui-designer)`, unit mass): overshoot fraction M and time to the first peak
  t give ζ = -ln M / sqrt(π² + ln² M) and ω = π / (t sqrt(1 - ζ²)), so k = ω² and c = 2ζω (checked against a
  simulated k 200, c 10).
- Game feel: the same frame stepping. Jump: apex height h and time to apex t give gravity 2h/t² and take-off speed
  2h/t; the fall timed on its own shows whether falling uses a stronger gravity. Also acceleration and stopping frames,
  coyote time and the input buffer (jump pressed at known frame offsets around the ledge and the landing), hit-stop
  frames, shake amplitude and decay, input-to-screen latency. A Godot game's real constants are in its scripts
  (gdsdecomp, above) - read them before measuring.
- Sound: `ffprobe` for the format; loudness with `ffmpeg -i S -af ebur128 -f null -` (integrated I and LRA in the
  closing summary); the spectrum with `ffmpeg -i S -lavfi showspectrumpic=s=1024x512 re/spec.png`. A tracker module
  (.mod, .xm, .it) is its own spec.

One frame at 60 fps is 16.7 ms: that is the error bar on every timing taken from a capture.
