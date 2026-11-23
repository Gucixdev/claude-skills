#!/usr/bin/env bats
# tools/graphify-sync: the post-commit hook install (-i) and the usage text; graph building needs graphify, not tested here.

setup() {
	S=$BATS_TEST_DIRNAME/../tools/graphify-sync
	export GRAPHIFY_BIN=/bin/true
	git init -q "$BATS_TEST_TMPDIR/r"
}

@test "graphify-sync -i installs the post-commit hook once and keeps an existing hook" {
	run "$S" -i "$BATS_TEST_TMPDIR/r"
	[ "$status" -eq 0 ]
	[[ $output == *"hook   r"* ]]
	h=$BATS_TEST_TMPDIR/r/.git/hooks/post-commit
	[ -x "$h" ]
	run "$S" -i "$BATS_TEST_TMPDIR/r"
	[ -z "$output" ]
	[ "$(grep -c graphify-sync "$h")" -eq 2 ]
	printf '#!/bin/sh\necho mine\n' > "$BATS_TEST_TMPDIR/r/.git/hooks/pre-commit"
	git init -q "$BATS_TEST_TMPDIR/q"
	printf '#!/bin/sh\necho mine\n' > "$BATS_TEST_TMPDIR/q/.git/hooks/post-commit"
	run "$S" -i "$BATS_TEST_TMPDIR/q"
	grep -q 'echo mine' "$BATS_TEST_TMPDIR/q/.git/hooks/post-commit"
	grep -q 'graphify-sync' "$BATS_TEST_TMPDIR/q/.git/hooks/post-commit"
}

@test "graphify-sync -m needs two graphs" {
	printf '%s\n' "$BATS_TEST_TMPDIR/r" > "$BATS_TEST_TMPDIR/list"
	run env GRAPHIFY_REPOS="$BATS_TEST_TMPDIR/list" "$S" -m
	[ "$status" -eq 1 ]
	[[ $output == *"at least two graphs"* ]]
}
