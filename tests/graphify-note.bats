#!/usr/bin/env bats
# tools/graphify-note: own nodes beside the generated graphs, on a hand-made graph.

setup() {
	N=$BATS_TEST_DIRNAME/../tools/graphify-note
	export GRAPHIFY_HOME=$BATS_TEST_TMPDIR/g
	mkdir -p "$GRAPHIFY_HOME/r"
	printf '{"nodes":[{"id":"a_main","label":"main","norm_label":"main"}],"links":[]}\n' > "$GRAPHIFY_HOME/r/graph.json"
}

@test "graphify-note adds a linked note, replaces it by label, lists and removes it" {
	run "$N" "Why main" "entry point stays small" r:main
	[ "$status" -eq 0 ]
	run jq -c '.links[0] | [.source, .target, .relation]' "$GRAPHIFY_HOME/_notes/graph.json"
	[ "$output" = '["note::why_main","r::a_main","about"]' ]
	run "$N" "Why main" "changed text" r:main
	run "$N" -l
	[ "$output" = $'Why main\tchanged text' ]
	[ "$(jq '.links | length' "$GRAPHIFY_HOME/_notes/graph.json")" -eq 1 ]
	"$N" -d "Why main"
	[ -z "$("$N" -l)" ]
}

@test "graphify-note refuses a symbol or a repo that is not in the graphs" {
	run "$N" x y r:nosuch
	[ "$status" -eq 1 ]
	[[ $output == *"no node nosuch"* ]]
	run "$N" x y nope:main
	[ "$status" -eq 1 ]
}
