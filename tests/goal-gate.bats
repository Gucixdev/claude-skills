#!/usr/bin/env bats
# hooks/goal-gate, the Stop hook that keeps Claude working until a check passes, in throwaway folders.

setup() {
	G=$BATS_TEST_DIRNAME/../hooks/goal-gate
	export GOAL_GATE_DIR=$BATS_TEST_TMPDIR/store
	export TMPDIR=$BATS_TEST_TMPDIR
	W=$BATS_TEST_TMPDIR/proj
	mkdir -p "$W/sub"
	W=$(cd "$W" && pwd -P)
	export CLAUDE_PROJECT_DIR=$W
}

stop() { echo '{"hook_event_name":"Stop","stop_hook_active":false}' | "$G"; }

goal() {	# goal LINE...: register the lines as the goal of $W
	f=$("$G" path "$W")
	printf '%s\n' "$@" > "$f"
}

@test "no goal: the hook lets Claude stop and prints nothing" {
	run stop
	[ "$status" -eq 0 ] && [ -z "$output" ]
	run "$G" show "$W"
	[ "$status" -eq 1 ]
}

@test "a goal file planted in the project is ignored" {
	mkdir -p "$W/.claude"
	echo 'touch "$HOME/pwned"; false' > "$W/.claude/goal"
	run stop
	[ "$status" -eq 0 ] && [ -z "$output" ]
}

@test "path: the versions-store naming, inside the store" {
	run "$G" path "$W"
	[ "$status" -eq 0 ]
	[ "$output" = "$GOAL_GATE_DIR/$(printf '%s' "$W" | sed 's/!/!!/g; s|/|!|g')" ]
	run "$G" path "$W/missing"
	[ "$status" -eq 2 ]
}

@test "failing check: exit 2 with the goal, the output tail and a try line; past max it gives up once" {
	goal '# the answer is right' '# max: 2' 'echo "got 41"' 'test "$(cat answer)" = 42'
	echo 41 > "$W/answer"
	run stop
	[ "$status" -eq 2 ]
	[[ "$output" == *"Goal not met (try 1 of 2, the check exited 1): the answer is right"* ]]
	[[ "$output" == *"got 41"* ]]
	run stop
	[ "$status" -eq 2 ] && [[ "$output" == *"try 2 of 2"* ]]
	[ "$(grep -c '^# try:' "$f")" -eq 2 ]
	run stop
	[ "$status" -eq 1 ] && [[ "$output" == *"not met after 2 tries"* ]]
	grep -q '^# gave up:' "$f"
	run stop
	[ "$status" -eq 0 ] && [ -z "$output" ]
}

@test "passing check: Claude stops, the goal is marked met and not run again" {
	goal '# the answer is right' 'test "$(cat answer)" = 42'
	echo 42 > "$W/answer"
	run stop
	[ "$status" -eq 0 ] && [ -z "$output" ]
	grep -q '^# met:' "$f"
	echo 41 > "$W/answer"
	run stop
	[ "$status" -eq 0 ]
	[ "$(grep -c '^# try:' "$f")" -eq 0 ]
}

@test "every line must pass, and the check runs in the goal's folder even from a subfolder" {
	goal '# both' 'false' 'true'
	run stop
	[ "$status" -eq 2 ]
	goal '# runs at the top' 'test -d sub'
	CLAUDE_PROJECT_DIR=$W/sub run stop
	[ "$status" -eq 0 ]
	CLAUDE_PROJECT_DIR=$W/sub run "$G" show "$W/sub"
	[ "$status" -eq 0 ] && [[ "$output" == *"# runs in: $W"* ]]
}

@test "the project folder falls back to the cwd in the hook input" {
	goal '# never' 'false'
	run bash -c "unset CLAUDE_PROJECT_DIR; echo '{\"cwd\": \"$W\"}' | '$G'"
	[ "$status" -eq 2 ]
}

@test "a slow check is cut at its timeout and counts as not met" {
	goal '# fast enough' '# timeout: 1' 'sleep 5'
	run stop
	[ "$status" -eq 2 ] && [[ "$output" == *"timed out after 1s"* ]]
}

@test "path moves a finished goal aside instead of reusing it" {
	goal '# done' 'true'
	stop
	run "$G" path "$W"
	[ "$status" -eq 0 ] && [ ! -e "$output" ]
	ls "$GOAL_GATE_DIR" | grep -q '\.[0-9]\{8\}-[0-9]\{6\}$'
}
