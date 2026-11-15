# ui (media-cli)

## Habits

If the user has format-conversion or repair wrappers installed, use them first; otherwise the tools below. A wrapper
worth having picks the backend by the two file extensions (magick/ffmpeg for images, audio and video, assimp for 3D
models, fontforge for fonts, pandoc for documents), never overwrites without a flag, and can repair a broken file into a
new name (re-mux, then re-encode). Originals are never overwritten: new names, or the old file to the trash first
(`rules (trash-not-rm)`).

## ImageMagick

IM7 is `magick`; IM6 only has `convert`/`identify`/`mogrify` - check which exists.
- Info: `magick identify -format '%w %h %m %[colorspace]\n' IMG`
- Resize: `-resize 50%`, `-resize '800x800>'` (only shrink), pixel art `-filter point -resize 400%`
- Crop and trim: `-crop WxH+X+Y +repage`, `-trim +repage`; split a sprite sheet `-crop 32x32 +repage frame_%03d.png`
- Sheet from frames: `magick montage f_*.png -tile 8x -geometry +0+0 -background none sheet.png`
- Palette: `-colors 16 +dither`; WebP `-quality 85 out.webp`
- Text and font previews: `magick -size 480x64 xc:black -font FILE -pointsize 13 -fill '#33ff33' -annotate +8+24 'The
  quick brown fox' out.png`
- Compare: `magick compare -metric AE a.png b.png diff.png` (pixel count on stderr, exit 1 when they differ)
- Batch into a new folder, originals untouched: `mogrify -path out/ -resize 50% *.png`
- PDF and PS may be blocked by the security policy: `pdftoppm -r 150 -png in.pdf page` instead.

## ffmpeg

- Probe: `ffprobe -v error -show_format -show_streams -of json IN`
- Remux, no re-encode: `ffmpeg -i in.mkv -c copy out.mp4`
- Trim fast (cuts on keyframes): `ffmpeg -ss 00:01:00 -to 00:02:00 -i IN -c copy OUT`; frame-accurate: re-encode
- H.264: `-c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p -c:a aac -b:a 160k`; AV1 `-c:v libsvtav1 -crf 35`
- An older NVIDIA GPU (Pascal): `h264_nvenc` and `hevc_nvenc` encode (no AV1); check `ffmpeg -hide_banner -encoders | grep
  nvenc` and the flags with `ffmpeg -h encoder=h264_nvenc`
- GIF with a real palette: `-vf "fps=15,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse"`
- Audio only: `-vn -c:a libopus -b:a 96k out.opus`; loudness `-af loudnorm`
- Frames out `-vf fps=1 f_%04d.png`; frames in `-framerate 30 -i f_%04d.png -c:v libx264 -pix_fmt yuv420p out.mp4`
- Concat same-codec files: a list file of `file 'a.mp4'` lines, `-f concat -safe 0 -i list.txt -c copy out.mp4`
- Burn subtitles `-vf subtitles=sub.srt`

## Fonts

- Find: `fc-list : family file`, `fc-match 'Fixed'`; after adding fonts to `~/.local/share/fonts`: `fc-cache -f`.
- Convert: fontforge; inspect and subset with fonttools (`ttx -l FONT`, `pyftsubset FONT --unicodes=...`);
  bitmap BDF/PCF to OpenType bitmap with `fonttosfnt -o OUT.otb IN.bdf` (Wayland terminals take OTB, not PCF).
- Bitmap faces: misc-fixed 6x13, the TempleOS 8x8 look (`ui (ui-designer)`).
- Licenses before bundling a font in a game or app: SIL OFL fonts can be bundled (not sold alone); GNU FreeFont
  (FreeMono, FreeSans, FreeSerif) is GPLv3 with the font exception, so documents using it are not GPL.

## 3D models (assimp)

- `assimp info MODEL` - meshes, materials, animations; `assimp listext` (imports), `assimp listexport` (exports).
- Convert to glTF (the format Godot and most engines take): `assimp export in.fbx out.glb` (format from the extension; check `assimp help export`).
- What assimp mangles (rigs, modifiers, materials) goes through Blender instead: `blender -b in.blend --python-expr 'import bpy; bpy.ops.export_scene.gltf(filepath="out.glb")'`.
