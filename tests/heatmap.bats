#!/usr/bin/env bats
# tools/heatmap: who wrote what, models, periods, and used/unused/running of tools, skills and hooks, on made-up transcripts.

setup() {
	W=$BATS_TEST_TMPDIR/public
	mkdir -p "$W/tools" "$W/skills/s-used" "$W/skills/s-idle" "$W/hooks" "$BATS_TEST_TMPDIR/proj/-p1/sess/subagents"
	cp "$BATS_TEST_DIRNAME/../tools/heatmap" "$W/tools/heatmap"
	touch "$W/tools/t-used" "$W/tools/t-idle" "$W/hooks/h-used" "$W/hooks/h-idle"
	T=$BATS_TEST_TMPDIR/proj/-p1/main.jsonl
	cat > "$T" <<'J'
{"type":"user","origin":{"kind":"human"},"timestamp":"2026-11-20T10:00:00.000Z"}
{"type":"assistant","timestamp":"2026-11-20T10:00:05.000Z","message":{"model":"model-a","content":[{"type":"tool_use","name":"Bash","input":{"command":"cd x && t-used --flag"}},{"type":"tool_use","name":"Skill","input":{"skill":"s-used"}}]}}
{"type":"attachment","timestamp":"2026-11-20T10:00:06.000Z","attachment":{"type":"hook_success","command":"~/.claude/hooks/h-used"}}
{"type":"user","origin":{"kind":"human"},"timestamp":"2027-01-02T10:00:00.000Z"}
J
	cat > "$BATS_TEST_TMPDIR/proj/-p1/sess/subagents/agent-1.jsonl" <<'J'
{"type":"assistant","isSidechain":true,"timestamp":"2026-11-20T11:00:00.000Z","message":{"model":"model-b","content":[]}}
J
	export CLAUDE_PROJECTS=$BATS_TEST_TMPDIR/proj
}

@test "who and models: you, agent and subagent are counted apart, with the model" {
	run "$W/tools/heatmap"
	[ "$status" -eq 0 ]
	[[ "$output" =~ you\ +2 ]]
	[[ "$output" =~ agent\ +1 ]]
	[[ "$output" =~ subagent\ +1 ]]
	[[ "$output" == *"model-a"* && "$output" == *"model-b"* ]]
}

@test "-b year and -b day bucket the timeline" {
	run "$W/tools/heatmap" -b year
	[[ "$output" == *"2026 "* && "$output" == *"2027 "* ]]
	run "$W/tools/heatmap" -b day
	[[ "$output" == *"2026-11-20"* && "$output" == *"2027-01-02"* ]]
	run "$W/tools/heatmap" -b hour
	[[ "$output" == *"2026-11-20 1"*":00"* ]]
}

@test "-u: used, unused for tools, skills and hooks" {
	run "$W/tools/heatmap" -u
	[ "$status" -eq 0 ]
	[[ "$output" == *"tools: 1 used, 2 unused"* ]]       # heatmap itself is a tool and is not named in the made-up commands
	[[ "$output" =~ t-used\ +used\ +1 ]]
	[[ "$output" =~ t-idle\ +unused\ +0 ]]
	[[ "$output" == *"skills: 1 used, 1 unused"* ]]
	[[ "$output" == *"hooks: 1 used, 1 unused"* ]]
	[[ "$output" =~ h-used\ +used\ +1 ]]
}

@test "-u: a process of a tool counts as running" {
	cp /bin/sleep "$W/tools/t-idle" && chmod +x "$W/tools/t-idle"
	"$W/tools/t-idle" 30 & pid=$!
	run "$W/tools/heatmap" -u
	kill "$pid"
	[[ "$output" =~ t-idle\ +unused\ +0\ +-\ +yes ]]
}

@test "bad usage exits 2, no transcripts exits 1" {
	run "$W/tools/heatmap" -b week
	[ "$status" -eq 2 ]
	run "$W/tools/heatmap" -d abc
	[ "$status" -eq 2 ]
	CLAUDE_PROJECTS=$BATS_TEST_TMPDIR/none run "$W/tools/heatmap"
	[ "$status" -eq 1 ]
}
