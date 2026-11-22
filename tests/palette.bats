#!/usr/bin/env bats
# tools/palette: colour maths against known values, contrast, schemes, full accent sets, errors.

setup() {
	P=$BATS_TEST_DIRNAME/../tools/palette
}

# lib 'python code': run the code with the tool loaded as module p (isolated mode, no site or cwd imports)
lib() {
	python3 -I -c 'import importlib.machinery as m, importlib.util as u, sys
sys.dont_write_bytecode = True
l = m.SourceFileLoader("palette", sys.argv[1]); s = u.spec_from_loader("palette", l)
p = u.module_from_spec(s); l.exec_module(p)
'"$1" "$P"
}

@test "py_compile is clean" {
	python3 -I -c 'import py_compile, sys; py_compile.compile(sys.argv[1], cfile=sys.argv[2], doraise=True)' \
		"$P" "$BATS_TEST_TMPDIR/palette.pyc"
}

@test "oklab: white is L 1 and black is 0, both achromatic" {
	lib '
w = p.rgb_to_oklch((255, 255, 255)); k = p.rgb_to_oklch((0, 0, 0))
assert abs(w[0] - 1) < 1e-6 and w[1] < 1e-6, w
assert k[0] == 0 and k[1] == 0, k
'
}

@test "oklch of the sRGB primaries and a grey match published values (CSS Color 4 / ImageMagick)" {
	lib '
known = {(255, 0, 0): (0.62796, 0.25768, 29.23), (0, 255, 0): (0.86644, 0.29483, 142.50),
         (0, 0, 255): (0.45201, 0.31321, 264.05), (128, 128, 128): (0.59987, 0.0, 0.0)}
for rgb, (L, c, h) in known.items():
    got = p.rgb_to_oklch(rgb)
    assert abs(got[0] - L) < 2e-5 and abs(got[1] - c) < 2e-5, (rgb, got)
    assert c == 0 or abs(got[2] - h) < 0.01, (rgb, got)
'
}

@test "oklab: independent cross-check against ImageMagick when it is installed" {
	command -v magick >/dev/null || skip "no magick"
	for hx in 3366ff ffcc00 123456 fedcba; do
		read -r L a b < <(magick "xc:#$hx" -colorspace OKLab -format '%[fx:u.r] %[fx:u.g-0.5] %[fx:u.b-0.5]' info: | tr -s ' '; echo)
		lib "
rgb = p.parse_hex('$hx')
L2, a2, b2 = p.oklch_to_oklab(*p.rgb_to_oklch(rgb))
assert max(abs(L2 - $L), abs(a2 - ($a)), abs(b2 - ($b))) < 2e-5, (L2, a2, b2)
"
	done
}

@test "oklch -> rgb round-trips every channel of sampled colours" {
	lib '
import itertools
for rgb in itertools.product(range(0, 256, 51), repeat=3):
    assert p.oklch_to_rgb(*p.rgb_to_oklch(rgb)) == rgb, rgb
'
}

@test "gamut clip: result always fits sRGB, keeps L and hue, only lowers chroma, is maximal" {
	lib '
n = 0
for L in [i / 20 for i in range(0, 21)]:
    for c in [0.05, 0.15, 0.3, 0.4]:
        for h in range(0, 360, 15):
            L2, c2, h2 = p.gamut_clip(L, c, h)
            assert L2 == L and h2 == h and c2 <= c + 1e-12, (L, c, h, c2)
            assert p.in_gamut(p.oklch_to_lin(L2, c2, h2)), (L, c, h)
            if c2 < c:
                n += 1
                assert not p.in_gamut(p.oklch_to_lin(L2, c2 + 0.002, h2)), (L, c, h, c2)
assert n > 100  # the grid does contain out-of-gamut colours
'
}

@test "wcag: contrast of known pairs" {
	run "$P" check '#000000' '#ffffff'
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" == *"contrast 21.00:1" ]]
	lib '
c = p.contrast
assert abs(c((0, 0, 0), (255, 255, 255)) - 21) < 1e-9
assert abs(c((255, 255, 255), (0, 0, 0)) - 21) < 1e-9
assert abs(c((255, 255, 255), (255, 255, 255)) - 1) < 1e-9
assert abs(c((0x76, 0x76, 0x76), (255, 255, 255)) - 4.54) < 0.005   # the well-known AA grey
assert abs(c((0, 0, 255), (255, 255, 255)) - 8.59) < 0.005
assert abs(c((255, 0, 0), (255, 255, 255)) - 4.00) < 0.005
assert abs(p.luminance((255, 0, 0)) - 0.2126) < 1e-9
'
}

@test "check: AA/AAA table and exit code at the 4.5 border" {
	run "$P" check 767676 fff
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" == *"4.54:1" ]]
	[[ "${lines[1]}" == "normal text  AA pass  AAA FAIL" ]]
	[[ "${lines[2]}" == "large text  AA pass  AAA pass" ]]
	run "$P" check 777 fff
	[ "$status" -eq 1 ]
	[[ "${lines[1]}" == "normal text  AA FAIL  AAA FAIL" ]]
	[[ "${lines[2]}" == "large text  AA pass  AAA FAIL" ]]
	run "$P" check '#ffff00' '#ffffff'
	[ "$status" -eq 1 ]
	[[ "${lines[2]}" == "large text  AA FAIL  AAA FAIL" ]]
}

@test "check: --json is valid and agrees with the exit code" {
	run "$P" check 000 fff --json
	[ "$status" -eq 0 ]
	python3 -I -c 'import json, sys
d = json.loads(sys.argv[1]); assert d["ratio"] == 21.0 and d["normal"]["AAA"] and d["large"]["AAA"]' "$output"
}

@test "gen: default sizes, accent-1 is the seed, names and format" {
	for pair in analogous:3 complementary:2 triadic:3 split:3 tetradic:4 mono:5; do
		run "$P" gen '#3366ff' --scheme "${pair%%:*}"
		[ "$status" -eq 0 ]
		[ "${#lines[@]}" -eq "${pair##*:}" ]
		for l in "${lines[@]}"; do [[ $l =~ ^accent-[0-9]+\ #[0-9A-F]{6}$ ]]; done
	done
	run "$P" gen 36f
	[ "${lines[0]}" = "accent-1 #3366FF" ]
	run "$P" gen 3366ff --n 9 --scheme tetradic
	[ "${#lines[@]}" -eq 9 ]
}

@test "gen: hues rotate by the scheme's angles" {
	lib '
seed = p.parse_hex("#3366ff"); h0 = p.rgb_to_oklch(seed)[2]
def hues(scheme):
    return [(p.rgb_to_oklch(c)[2] - h0) % 360 for c in p.gen(seed, scheme, p.NATURAL[scheme])]
def near(a, b): return min(abs(a - b), 360 - abs(a - b)) < 4
for scheme, want in {"complementary": [0, 180], "triadic": [0, 120, 240], "split": [0, 150, 210],
                     "tetradic": [0, 90, 180, 270], "analogous": [0, 30, 330]}.items():
    got = hues(scheme)
    assert all(near(g, w) for g, w in zip(got, want)), (scheme, got)
assert all(near(g, 0) for g in hues("mono"))
'
}

@test "gen: out-of-gamut and extreme seeds produce valid colours with the right hue, any scheme" {
	for seed in '#00ff00' '#0000ff' '#ff00ff' '#00ffff' '#ffff00' '#ffffff' '#000000' '#808080'; do
		for scheme in analogous complementary triadic split tetradic mono; do
			run "$P" gen "$seed" --scheme $scheme --n 12
			[ "$status" -eq 0 ]
			[ "${#lines[@]}" -eq 12 ]
			for l in "${lines[@]}"; do [[ $l =~ ^accent-[0-9]+\ #[0-9A-F]{6}$ ]]; done
		done
	done
	lib '
# #00ff00 sits at the edge of sRGB: every derived colour must come from the clipped, hue-true OKLCH colour
seed = p.parse_hex("#00ff00")
for scheme in p.NATURAL:
    for rgb in p.gen(seed, scheme, 12)[1:]:
        L, c, h = p.rgb_to_oklch(rgb)
        assert p.in_gamut(p.oklch_to_lin(L, c, h), 1e-4), (scheme, rgb)
        assert all(0 <= v <= 255 for v in rgb)
'
}

@test "gen: --json is valid, same names and hex as the text output" {
	run "$P" gen '#3366ff' --scheme triadic
	text=$output
	run "$P" gen '#3366ff' --scheme triadic --json
	python3 -I -c 'import json, sys
d = json.loads(sys.argv[1])
assert d["seed"] == "#3366FF" and d["scheme"] == "triadic"
assert "\n".join(c["name"] + " " + c["hex"] for c in d["colors"]) == sys.argv[2]' "$output" "$text"
}

@test "gen: deterministic, --opt=value works" {
	a=$("$P" gen '#e91e63' --scheme=split --n=5)
	b=$("$P" gen e91e63 --n 5 --scheme split)
	[ "$a" = "$b" ]
}

# every text pair of a set, as "fg bg" lines of the JSON on stdin
pairs() {
	python3 -I -c 'import json, sys
d = json.load(sys.stdin)
for mode in ("light", "dark"):
    m = d[mode]
    for fg in ("text", "muted", "accent", "accent-hover", "success", "warning", "danger"):
        for bg in ("bg", "surface"):
            print(m[fg], m[bg])'
}

@test "set: every text/background pair passes palette check for many seeds, light and dark" {
	for seed in '#3366ff' '#00ff00' '#ffee00' '#ff0000' '#000000' '#ffffff' '#808080' '#0a0a0a' '#f5f5dc' '#e91e63' '#00ffff' '#123456'; do
		json=$("$P" set "$seed" --json)
		n=0
		while read -r fg bg; do
			run "$P" check "$fg" "$bg"
			[ "$status" -eq 0 ] || { echo "$seed: $fg on $bg"; false; }
			n=$((n + 1))
		done < <(pairs <<<"$json")
		[ "$n" -eq 28 ]
	done
}

@test "set: CSS custom properties for both modes, every role, header says AA" {
	run "$P" set '#3366ff'
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" == "/* palette set #3366FF: every text pair AA >= 4.5:1, lowest "* ]]
	[[ "$output" != *FAILED* ]]
	[[ "$output" == *":root {"* && "$output" == *"@media (prefers-color-scheme: dark)"* ]]
	for role in bg surface border text muted accent accent-hover success warning danger; do
		[ "$(grep -cE "^ +--$role: #[0-9A-F]{6};$" <<<"$output")" -eq 2 ]
	done
}

@test "set: --json has both modes with all ten roles and reports aa_ok" {
	run "$P" set '#00ff00' --json
	[ "$status" -eq 0 ]
	python3 -I -c 'import json, sys
d = json.loads(sys.argv[1])
roles = "bg surface border text muted accent accent-hover success warning danger".split()
assert d["aa_ok"] is True and d["failed"] == []
for mode in ("light", "dark"):
    assert list(d[mode]) == roles, d[mode]' "$output"
}

@test "set: light mode is light, dark mode is dark, accent keeps the seed hue" {
	lib '
for seed in ["#3366ff", "#e91e63", "#00ff00"]:
    modes, fails = p.build_set(p.parse_hex(seed))
    assert fails == []
    h0 = p.rgb_to_oklch(p.parse_hex(seed))[2]
    assert p.luminance(p.parse_hex(modes["light"]["bg"])) > 0.9
    assert p.luminance(p.parse_hex(modes["dark"]["bg"])) < 0.02
    for mode in modes.values():
        h = p.rgb_to_oklch(p.parse_hex(mode["accent"]))[2]
        assert min(abs(h - h0), 360 - abs(h - h0)) < 6, (seed, h, h0)
'
}

@test "set: fit says so when no lightness reaches AA, and set then exits 1 with the failure on stderr" {
	lib '
rgb, ok = p.fit(0.5, 0.0, 0.0, [(60, 60, 60)], -1)   # darker than black is impossible
assert ok is False
rgb, ok = p.fit(0.5, 0.0, 0.0, [(255, 255, 255)], -1)
assert ok is True and p.contrast(rgb, (255, 255, 255)) >= 4.5
import io, contextlib
modes, _ = p.build_set((51, 102, 255))
p.build_set = lambda seed: (modes, ["light: muted on bg = 3.00:1"])
out, err = io.StringIO(), io.StringIO()
with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
    code = p.cmd_set(["#3366ff"])
assert code == 1 and "FAILED: light: muted on bg" in out.getvalue()
assert "could not reach AA - light: muted on bg" in err.getvalue()
'
}

@test "set: deterministic" {
	[ "$("$P" set '#3366ff')" = "$("$P" set 36f)" ]
	[ "$("$P" set '#3366ff' --json)" = "$("$P" set '#3366ff' --json)" ]
}

@test "errors: bad colours, schemes, counts, options and commands exit 2 with a message" {
	for args in "gen zz" "gen #12345" "gen #12345678" "check red fff" "check 000" "set" "set 000 fff" \
		"gen 000 --scheme nope" "gen 000 --n 0" "gen 000 --n 65" "gen 000 --n x" "gen 000 --n -1" "gen 000 --n" \
		"gen 000 --bogus" "set 000 --scheme mono" "check 000 fff --json=1" "frobnicate" ; do
		run "$P" $args
		[ "$status" -eq 2 ] || { echo "args: $args status $status"; false; }
		[[ "$output" == palette:* ]] || { echo "args: $args output $output"; false; }
		[[ "$output" != *Traceback* ]]
	done
	run "$P" gen zz
	[[ "${lines[0]}" == "palette: invalid colour 'zz' (expected #RGB or #RRGGBB)" ]]
	run "$P" gen 000 --scheme nope
	[[ "${lines[0]}" == *"unknown scheme 'nope'"* && "${lines[0]}" == *"triadic"* ]]
}

@test "help: header comment, exit 0 on --help, exit 2 without arguments" {
	run "$P" --help
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" == "palette - colours that go together"* ]]
	[[ "$output" == *"Exit codes:"* && "$output" != *"import json"* ]]
	run "$P" gen --help
	[ "$status" -eq 0 ]
	run "$P"
	[ "$status" -eq 2 ]
	[[ "$output" == "palette - "* ]]
}
