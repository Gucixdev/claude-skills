#!/usr/bin/env bats
# skills/seed/scripts/seed: a GitHub repo (here a local git repo) becomes a new project - no history, renamed, his conventions.

setup() {
	S=$BATS_TEST_DIRNAME/../skills/seed/scripts/seed
	export HOME=$BATS_TEST_TMPDIR/home GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
	export GIT_AUTHOR_NAME=T GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=T GIT_COMMITTER_EMAIL=t@example.com
	export SEED_HOLDER=Gucixdev
	mkdir -p "$HOME"
	UP=$BATS_TEST_TMPDIR/upstream/oldtool
	mkdir -p "$UP/src/oldtool_lib" "$UP/skills/foo"
	cat > "$UP/oldtool" <<'X'
#!/usr/bin/env bash
# oldtool - say hello. OLDTOOL_HOME is where it keeps state.
echo "Oldtool says hello from ${OLDTOOL_HOME:-.}"
X
	chmod +x "$UP/oldtool"
	echo 'package oldtool_lib' > "$UP/src/oldtool_lib/oldtool_lib.go"
	printf '# Oldtool\n\nOldtool greets. See https://example.com/someone/oldtool for the original.\n' > "$UP/README.md"
	printf 'test:\n\t@echo tests ok\n\ninstall:\n\t@echo installing\n' > "$UP/Makefile"
	printf -- '---\nname: foo\ndescription: "Does foo."\nmetadata:\n  priority: "2"\n---\n# foo\nfoo things\n' > "$UP/skills/foo/SKILL.md"
	printf 'MIT License\n\nCopyright (c) 2020 Someone Else (oldtool authors)\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software.\n' > "$UP/LICENSE"
	git -C "$UP" init -q -b main && git -C "$UP" add -A && git -C "$UP" commit -qm "first"
	echo second > "$UP/second.txt" && git -C "$UP" add -A && git -C "$UP" commit -qm "second"
	W=$BATS_TEST_TMPDIR/work
	mkdir -p "$W"
	cd "$W" || exit 1
}

@test "MIT seed: renamed everywhere, one commit, no upstream .git, both licences kept" {
	run "$S" "$UP" newtool
	[ "$status" -eq 0 ]
	cd newtool
	[ -x newtool ] && [ ! -e oldtool ]
	[ -f src/newtool_lib/newtool_lib.go ]
	grep -q 'Newtool says hello from ${NEWTOOL_HOME' newtool
	! grep -rqi 'oldtool' --exclude=LICENSE --exclude=README.md .
	[ "$(git rev-list --count HEAD)" -eq 1 ]
	[ "$(git log -1 --format=%s)" = "feat: seed from oldtool@$(git -C "$UP" rev-parse --short HEAD)" ]
	grep -q 'Copyright (c) .* Gucixdev' LICENSE
	grep -q 'Someone Else (oldtool authors)' LICENSE	# the upstream notice is not rewritten
}

@test "README: renamed, the upstream URL left alone, an Origin section added" {
	"$S" "$UP" newtool
	grep -q '^# Newtool' newtool/README.md
	grep -q 'example.com/someone/oldtool' newtool/README.md
	grep -q '^## Origin' newtool/README.md
}

@test "test and install are made from what the project has; existing ones are kept" {
	"$S" "$UP" newtool
	cd newtool
	[ -x test ] && [ -x install ]
	run ./test
	[[ $output == *"tests ok"* ]]
	run ./install
	[[ $output == *"installing"* ]]
	run ./test extra
	[ "$status" -eq 2 ]
}

@test "no tests and nothing to install: the scripts exist and say so, with a failing status" {
	rm "$UP/Makefile" && git -C "$UP" add -A && git -C "$UP" commit -qm nomake
	"$S" "$UP" newtool
	run newtool/test
	[ "$status" -eq 1 ] && [[ $output == *"no tests"* ]]
	run newtool/install
	[ "$status" -eq 1 ] && [[ $output == *"nothing to install"* ]]
}

@test "copyleft licence: refused, nothing created; -f seeds it and keeps the upstream licence" {
	printf 'GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007\n' > "$UP/LICENSE"
	git -C "$UP" add -A && git -C "$UP" commit -qm gpl
	run "$S" "$UP" newtool
	[ "$status" -eq 1 ] && [[ $output == *"copyleft"* ]]
	[ ! -e newtool ]
	run "$S" -f "$UP" newtool
	[ "$status" -eq 0 ]
	grep -q 'GNU GENERAL PUBLIC LICENSE' newtool/LICENSE
	! grep -q 'Gucixdev' newtool/LICENSE
}

@test "no licence file: refused (all rights reserved)" {
	git -C "$UP" rm -q LICENSE && git -C "$UP" commit -qm nolicense
	run "$S" "$UP" newtool
	[ "$status" -eq 1 ] && [[ $output == *"no licen"* ]]
	[ ! -e newtool ]
}

@test "Apache-2.0 stays Apache-2.0 (not relicensed) with a NOTICE for the changes" {
	printf 'Apache License\nVersion 2.0, January 2004\n' > "$UP/LICENSE"
	git -C "$UP" add -A && git -C "$UP" commit -qm apache
	run "$S" "$UP" newtool
	[ "$status" -eq 0 ]
	grep -q 'Apache License' newtool/LICENSE
	! grep -q 'MIT' newtool/LICENSE
	grep -q 'Gucixdev' newtool/NOTICE
}

@test "bad name, existing target, missing source: refused with the right status" {
	run "$S" "$UP" 'Bad Name!'
	[ "$status" -eq 2 ]
	mkdir newtool
	run "$S" "$UP" newtool
	[ "$status" -eq 1 ] && [[ $output == *"exists"* ]]
	run "$S" "$BATS_TEST_TMPDIR/none" other
	[ "$status" -eq 1 ]
	run "$S"
	[ "$status" -eq 2 ]
}

@test "skill seed: -s with //subdir takes only that folder, sets name and upstream" {
	run "$S" -s "$UP//skills/foo" bar
	[ "$status" -eq 0 ]
	cd bar
	grep -q '^name: bar$' SKILL.md
	grep -q '^  upstream: "oldtool@' SKILL.md
	grep -q '^# bar' SKILL.md
	[ ! -e oldtool ] && [ ! -e Makefile ]
}

@test "-d puts the project under another directory" {
	mkdir out
	run "$S" -d out "$UP" newtool
	[ "$status" -eq 0 ]
	[ -x out/newtool/newtool ]
}

@test "a ./test the seed brought is kept as it is" {
	printf '#!/bin/sh\necho their own test\n' > "$UP/test" && chmod +x "$UP/test"
	git -C "$UP" add -A && git -C "$UP" commit -qm own
	run "$S" "$UP" newtool
	[ "$status" -eq 0 ]
	run newtool/test
	[ "$output" = "their own test" ]
}
