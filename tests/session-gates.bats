#!/usr/bin/env bats
# hooks/session-start, hooks/session-end, hooks/memorize-gate, on throwaway repos and hand-made transcripts.

setup() {
	H=$BATS_TEST_DIRNAME/../hooks
	T=$BATS_TEST_TMPDIR
	export SESSION_GATE_DIR=$T/state SESSION_CONFIG_DIR=$T/cfg SESSION_REPOS=$T/repos TMPDIR=$T/tmp
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	mkdir -p "$T/cfg/skills/claude" "$T/repos" "$T/tmp"
	printf '%s\n' '# todo' '' 'old thing -> zrobione 2026-11-15' 'stuck one (blocked: hardware)' 'the next open one' > "$T/cfg/todo.md"
	printf '%s\n' '- desktop: Rust or C?' > "$T/cfg/questions.md"
	printf '%s\n' '### Priority 0 - always' '- `claude` #meta' '- `code` #dev' '### Priority 1' '- `machine` #x' > "$T/cfg/skills/claude/SKILL.md"
	R=$T/repos/proj
	git init -q "$R" && touch "$R/a" "$R/mine" && git -C "$R" add . && git -C "$R" commit -qm init
}

ev() { printf '{"hook_event_name":"%s","session_id":"s1","transcript_path":"%s","cwd":"%s"}' "$1" "$T/tr.jsonl" "$R"; }
user() { jq -cn --arg t "$1" '{type:"user",message:{role:"user",content:$t}}' >> "$T/tr.jsonl"; }
tool() { jq -cn --arg n "$1" --arg f "$2" '{type:"assistant",message:{content:[{type:"tool_use",name:$n,input:{file_path:$f}}]}}' >> "$T/tr.jsonl"; }

@test "session-start: the top open todo line, the priority-0 skills, the dirty repos" {
	echo x > "$R/mine"
	run "$H/session-start" < <(ev SessionStart)
	[ "$status" -eq 0 ]
	[[ $output == *"Top open line of todo.md: the next open one"* ]]
	[[ $output == *'`claude` `code`'* ]] && [[ $output != *machine* ]]
	[[ $output == *"proj: 1 files"* ]]
	grep -qxF "$R/mine" "$SESSION_GATE_DIR/dirty.s1" && [ -s "$SESSION_GATE_DIR/start.s1" ]
}

@test "session-start: questions answered since the last start, once" {
	"$H/session-start" < <(ev SessionStart) > /dev/null
	printf '%s\n' '- desktop: Rust or C? ODPOWIEDZ: C' > "$T/cfg/questions.md"
	run "$H/session-start" < <(ev SessionStart)
	[[ $output == *"ODPOWIEDZ: C"* ]]
	run "$H/session-start" < <(ev SessionStart)
	[[ $output != *"ODPOWIEDZ"* ]]
}

@test "session-end Stop: an edited file left uncommitted is handed back once" {
	"$H/session-start" < <(ev SessionStart) > /dev/null
	echo change > "$R/a"; tool Edit "$R/a"
	run "$H/session-end" < <(ev Stop)
	[ "$status" -eq 2 ] && [[ $output == *"$R/a"* ]]
	run "$H/session-end" < <(ev Stop)
	[ "$status" -eq 0 ]
	git -C "$R" commit -qam "fix: a"
	echo again > "$R/a"; git -C "$R" commit -qam "fix: a again"
	run "$H/session-end" < <(ev Stop)
	[ "$status" -eq 0 ] && [ -z "$output" ]
}

@test "session-end Stop: his files from before the session, files outside git and in /tmp are not listed" {
	echo his > "$R/mine"
	"$H/session-start" < <(ev SessionStart) > /dev/null
	echo more > "$R/mine"; tool Edit "$R/mine"
	echo y > "$T/loose"; tool Write "$T/loose"
	echo z > "$TMPDIR/scratch"; tool Write "$TMPDIR/scratch"
	run "$H/session-end" < <(ev Stop)
	[ "$status" -eq 0 ] && [ -z "$output" ]
	END_GATE=off run "$H/session-end" < <(ev Stop)
	[ "$status" -eq 0 ]
}

@test "session-end SessionEnd: a journal line with the session's commits, claude-config pushed when clean and ahead" {
	git init -q --bare "$T/remote.git"
	git clone -q "$T/remote.git" "$T/cfgrepo" 2> /dev/null
	cp -r "$T/cfg/." "$T/cfgrepo/" && git -C "$T/cfgrepo" add . && git -C "$T/cfgrepo" commit -qm init && git -C "$T/cfgrepo" push -q origin HEAD 2> /dev/null
	export SESSION_CONFIG_DIR=$T/cfgrepo
	mkdir -p "$SESSION_GATE_DIR" && echo 1 > "$SESSION_GATE_DIR/start.s1"	# the session began in 1970: every commit is in it
	echo c > "$R/a"; git -C "$R" commit -qam "feat: the work"; tool Edit "$R/a"
	echo n > "$T/cfgrepo/new"; git -C "$T/cfgrepo" add new; git -C "$T/cfgrepo" commit -qm "docs: new"
	run "$H/session-end" < <(ev SessionEnd)
	[ "$status" -eq 0 ]
	grep -q "1 files edited; commits: proj .* feat: the work" "$SESSION_GATE_DIR/journal.md"
	[ "$(git -C "$T/remote.git" log -1 --format=%s)" = "docs: new" ]
	echo dirty > "$T/cfgrepo/new"; git -C "$T/cfgrepo" commit -qam "docs: two" && echo d > "$T/cfgrepo/x"
	run "$H/session-end" < <(ev SessionEnd)
	[ "$(git -C "$T/remote.git" log -1 --format=%s)" = "docs: new" ]
}

@test "memorize-gate: a correction with no lesson after it is handed back once" {
	user "zrob hooki"
	user "przeciez masz plik questions.md gdzie zapisujesz pytania XD"
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 2 ] && [[ $output == *"przeciez masz plik questions.md"* ]]
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ]
}

@test "memorize-gate: the continuation summary after a compaction is not a correction" {
	user "zrob hooki"
	user "This session is being continued from a previous conversation that ran out of context. The user said wrong and I said no, znowu."
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ]
}

@test "memorize-gate: a lesson in a skill or the memory after the correction lets Claude stop" {
	user "nie, to zle"
	tool Edit "/x/claude-config/skills/rules/references/clarify.md"
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ]
	user "mowilem ze bez malloca"
	jq -cn '{type:"assistant",message:{content:[{type:"tool_use",name:"mcp__memory__memory_str_replace",input:{path:"/areas/x.md"}}]}}' >> "$T/tr.jsonl"
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ]
}

@test "memorize-gate: no correction, wrappers and an edit of ordinary code do not count" {
	user "to dawaj lecisz"
	user "no właśnie, o to chodzi"
	user "<command-name>/clear</command-name> nie"
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ] && [ -z "$output" ]
	user "znowu to samo"
	tool Edit "$R/a"
	run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 2 ]
	MEMORIZE_GATE=off run "$H/memorize-gate" < <(ev Stop)
	[ "$status" -eq 0 ]
}
