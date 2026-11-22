#!/usr/bin/env bats
# hooks/afk-gate, the Stop hook that keeps Claude working while he is away, with a throwaway state dir and todo file.

setup() {
	G=$BATS_TEST_DIRNAME/../hooks/afk-gate
	export AFK_GATE_DIR=$BATS_TEST_TMPDIR/state
	export AFK_GATE_TODO=$BATS_TEST_TMPDIR/todo.md
	printf '# todo\n\n1. old thing -> zrobione\n2. blocked on hardware (blocked)\n3. build the thing\n4. second thing\n' > "$AFK_GATE_TODO"
}

stop() { echo '{"hook_event_name":"Stop"}' | "$G"; }

@test "off by default: Claude may stop, nothing printed" {
	run stop
	[ "$status" -eq 0 ] && [ -z "$output" ]
	run "$G" status
	[ "$output" = "afk-gate: off" ]
}

@test "on (forced): the stop is blocked and the first open todo line comes back" {
	run "$G" on 1h
	[ "$status" -eq 0 ]
	run stop
	[ "$status" -eq 2 ]
	[[ $output == *"3. build the thing"* ]]
	[[ $output != *"old thing"* && $output != *"hardware"* ]]
	run "$G" status
	[[ $output == *"forced, "*"1 stops blocked"* ]]
}

@test "off switches it off again" {
	"$G" on 1h
	"$G" off
	run stop
	[ "$status" -eq 0 ]
}

@test "nothing open in todo.md: stopping is fine even when on" {
	printf '# todo\n1. a -> zrobione\n' > "$AFK_GATE_TODO"
	"$G" on 1h
	run stop
	[ "$status" -eq 0 ]
}

@test "the cap switches it off and tells him" {
	export AFK_GATE_MAX=2
	"$G" on 1h
	run stop; [ "$status" -eq 2 ]
	run stop; [ "$status" -eq 2 ]
	run stop; [ "$status" -eq 1 ]
	[[ $output == *"cap"* ]]
	run stop; [ "$status" -eq 0 ]
}

@test "an expired switch lets Claude stop" {
	mkdir -p "$AFK_GATE_DIR"
	echo $(($(date +%s) - 5)) > "$AFK_GATE_DIR/until"
	run stop
	[ "$status" -eq 0 ]
}

@test "bad duration and unknown command are usage errors" {
	run "$G" on abc
	[ "$status" -eq 2 ]
	run "$G" nonsense
	[ "$status" -eq 2 ]
}

# auto mode: the idle time comes from the newest human entry of the transcript, not from the clock of the switch

transcript() {	# transcript SECONDS_AGO: a human message that old, then a task notification and a tool result after it
	local f=$BATS_TEST_TMPDIR/t.jsonl
	{
		printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s"}\n' "$(date -u -d "-$1 sec" +%Y-%m-%dT%H:%M:%S.000Z)"
		printf '{"type":"user","origin":{"kind":"task-notification"},"timestamp":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
		printf '{"type":"assistant","timestamp":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
	} > "$f"
	echo "$f"
}
stop_t() { printf '{"hook_event_name":"Stop","transcript_path":"%s"}' "$1" | "$G"; }

@test "auto: quiet longer than the limit blocks the stop at once" {
	t=$(transcript 700)
	"$G" auto 10m
	run stop_t "$t"
	[ "$status" -eq 2 ]
	[[ $output == *"3. build the thing"* && $output == *"quiet for 11 minutes"* ]]
}

@test "auto: notifications and tool results do not reset the idle clock" {
	t=$(transcript 700)
	"$G" auto 10m
	run stop_t "$t"
	[ "$status" -eq 2 ]
}

@test "auto: he typed a moment ago, nothing waits forever: exit 0 after the wait" {
	t=$(transcript 5)
	AFK_GATE_WAIT=2 AFK_GATE_POLL=1 "$G" auto 10m
	AFK_GATE_WAIT=2 AFK_GATE_POLL=1 run stop_t "$t"
	[ "$status" -eq 0 ]
}

@test "auto: waits until the limit is reached, then blocks" {
	t=$(transcript 0)
	"$G" auto 3s
	AFK_GATE_WAIT=20 AFK_GATE_POLL=1 run stop_t "$t"
	[ "$status" -eq 2 ]
}

@test "auto: a new message from him during the wait ends it" {
	t=$(transcript 0)
	"$G" auto 1h
	( sleep 2; printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s"}\n' \
		"$(date -u -d '+3 sec' +%Y-%m-%dT%H:%M:%S.000Z)" >> "$t" ) &
	AFK_GATE_WAIT=20 AFK_GATE_POLL=1 run stop_t "$t"
	[ "$status" -eq 0 ]
}

@test "auto: no transcript means no block" {
	"$G" auto 1m
	run stop
	[ "$status" -eq 0 ]
	run stop_t /nonexistent
	[ "$status" -eq 0 ]
}

@test "auto: status shows the limit, off clears it, bad idle is a usage error" {
	"$G" auto 20m
	run "$G" status
	[[ $output == "afk-gate: auto, idle limit 20 min"* ]]
	"$G" off
	run "$G" status
	[ "$output" = "afk-gate: off" ]
	run "$G" auto 0m
	[ "$status" -eq 2 ]
	run "$G" auto x
	[ "$status" -eq 2 ]
}
