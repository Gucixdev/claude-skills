#!/usr/bin/env bats
# bin/skills-factory, and its two ends in hooks/end-session-gate (SessionEnd queues) and hooks/session-start (says
# how many wait), on a hand-made transcript.

setup() {
	F=$BATS_TEST_DIRNAME/../bin/skills-factory
	H=$BATS_TEST_DIRNAME/../hooks
	T=$BATS_TEST_TMPDIR
	export SESSION_GATE_DIR=$T/state SESSION_CONFIG_DIR=$BATS_TEST_DIRNAME/.. SESSION_REPOS=$T/none END_SESSION_PUSH=0
	user() { jq -cn --arg t "$1" '{type:"user",message:{role:"user",content:$t}}' >> "$T/tr.jsonl"; }
	tool() { jq -cn --arg n "$1" --arg k "$2" --arg v "$3" '{type:"assistant",message:{content:[{type:"tool_use",name:$n,input:{($k):$v}}]}}' >> "$T/tr.jsonl"; }
	user "zrob hooki do sesji"
	tool Bash command "git status --short"
	tool Bash command "git status"
	tool Edit file_path "/x/claude-config/hooks/session-start"
	user "przeciez masz plik questions.md gdzie zapisujesz pytania"
	tool Skill skill "workflow"
	user "od teraz zawsze rob z kazdej sesji skilla"
	jq -cn '{type:"user",message:{role:"user",content:[{type:"tool_result",content:"ok"}]}}' >> "$T/tr.jsonl"
	echo 'not json at all' >> "$T/tr.jsonl"
}

@test "digest: his corrections, wishes, words, the tools, commands, files and skills" {
	run "$F" digest "$T/tr.jsonl"
	[ "$status" -eq 0 ]
	[[ $output == *"his messages: 3; tool calls: 4"* ]]
	[[ $output == *$'## his corrections\n- przeciez masz plik questions.md'* ]]
	[[ $output == *$'## his wishes and rules (zawsze, nigdy, chce, od teraz...)\n- od teraz zawsze'* ]]
	[[ $output == *"- 2 Bash"* ]] && [[ $output == *"- 2 git status"* ]]
	[[ $output == *"- /x/claude-config/hooks/session-start"* ]] && [[ $output == *"- Skill: workflow"* ]]
}

@test "queue, list, next, done: the digest waits, then moves to done/ with what came of it" {
	run "$F" list
	[ "$status" -eq 1 ]
	"$F" queue "$T/tr.jsonl" s1 /x/claude-config
	run "$F" list
	[ "$status" -eq 0 ] && [[ $output == s1$'\t'*"folder: /x/claude-config"* ]]
	run "$F" next
	[[ $output == *"# session s1"* ]] && [[ $output == *'skills factory done s1 "what came of it"'* ]]
	"$F" done s1 "a line in skills/rules/references/clarify.md"
	[ ! -e "$SESSION_GATE_DIR/factory/s1.md" ]
	grep -q '^## done .*: a line in skills/rules' "$SESSION_GATE_DIR/factory/done/s1.md"
	run "$F" next
	[ "$status" -eq 1 ]
}

@test "a session with fewer than three of his messages is not queued" {
	jq -cn '{type:"user",message:{role:"user",content:"hej"}}' > "$T/short.jsonl"
	"$F" queue "$T/short.jsonl" s2
	run "$F" list
	[ "$status" -eq 1 ]
}

@test "SessionEnd queues the session; the next session-start says it waits" {
	printf '{"hook_event_name":"SessionEnd","session_id":"s3","transcript_path":"%s","cwd":"/x"}' "$T/tr.jsonl" | "$H/end-session-gate"
	[ -f "$SESSION_GATE_DIR/factory/s3.md" ]
	run "$H/session-start" < <(echo '{"hook_event_name":"SessionStart","session_id":"s4"}')
	[[ $output == *"Skill factory: 1 finished sessions wait to become skills"* ]]
	SKILLS_FACTORY=off run "$H/end-session-gate" < <(printf '{"hook_event_name":"SessionEnd","session_id":"s5","transcript_path":"%s"}' "$T/tr.jsonl")
	[ ! -f "$SESSION_GATE_DIR/factory/s5.md" ]
}

@test "skills factory through bin/skills, bad usage exits 2" {
	run "$BATS_TEST_DIRNAME/../bin/skills" factory digest "$T/tr.jsonl"
	[ "$status" -eq 0 ] && [[ $output == *"## his corrections"* ]]
	run "$F" bogus
	[ "$status" -eq 2 ]
}
