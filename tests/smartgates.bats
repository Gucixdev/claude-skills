#!/usr/bin/env bats
# hooks/smartgates and the gates built on it, on hand-made transcripts and throwaway repos.

setup() {
	H=$BATS_TEST_DIRNAME/../hooks
	T=$BATS_TEST_TMPDIR
	export SESSION_GATE_DIR=$T/state GRAPHIFY_HOME=$T/graphify
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	unset PUSH_GATE_ALLOW
	R=$T/proj
	git init -q "$R" && mkdir -p "$R/tests" && touch "$R/tests/a.bats" "$R/code.sh" && git -C "$R" add . && git -C "$R" commit -qm init
	: > "$T/tr.jsonl"
}

ev() { jq -cn --arg tr "$T/tr.jsonl" --arg cwd "$R" '{session_id: "s1", transcript_path: $tr, cwd: $cwd}'; }
pre() { jq -cn --arg tr "$T/tr.jsonl" --arg cwd "$R" --arg n "$1" --argjson i "$2" '{session_id: "s1", transcript_path: $tr, cwd: $cwd, tool_name: $n, tool_input: $i}'; }
user() { jq -cn --arg t "$1" '{type: "user", message: {role: "user", content: $t}}' >> "$T/tr.jsonl"; }
say() { jq -cn --arg t "$1" '{type: "assistant", message: {content: [{type: "text", text: $t}]}}' >> "$T/tr.jsonl"; }
edit() { jq -cn --arg f "$1" '{type: "assistant", message: {content: [{type: "tool_use", id: "e", name: "Edit", input: {file_path: $f}}]}}' >> "$T/tr.jsonl"; }
bash_() { jq -cn --arg id "$1" --arg c "$2" '{type: "assistant", message: {content: [{type: "tool_use", id: $id, name: "Bash", input: {command: $c}}]}}' >> "$T/tr.jsonl"; }
result() { jq -cn --arg id "$1" --argjson e "$2" '{type: "user", message: {content: [{type: "tool_result", tool_use_id: $id, is_error: $e, content: "x"}]}}' >> "$T/tr.jsonl"; }

@test "smartgates alone lists the gates" {
	run "$H/smartgates"
	[ "$status" -eq 0 ]
	for g in karpathy_gate knowsunknown_gate evolve_gate debug_gate test_gate caveman_gate leanctx_gate ponytail_gate graphify_gate mybashtoolgate readmegate updatedocsgate publish_gate tokenlimitgate; do
		[[ $output == *"$g"* ]]
	done
}

@test "debug_gate: a bug fix needs red then green in the same turn, once" {
	user "napraw ten bug"; edit "$R/code.sh"
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"no test run"* ]]
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "debug_gate: failing test, the fix, passing test: through; only green: asked for the red" {
	user "fix the crash"; bash_ t1 "bats tests/"; result t1 true; edit "$R/code.sh"; bash_ t2 "bats tests/"; result t2 false
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "fix the crash"; edit "$R/code.sh"; bash_ t2 "bats tests/"; result t2 false
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"no red run"* ]]
}

@test "debug_gate: a turn that is not a fix, or edits only docs, passes" {
	user "dodaj funkcje"; edit "$R/code.sh"
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"
	user "napraw to"; edit "$R/notes.md"
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "test_gate: edited code with tests to run and no green run is handed back once; green after the edit passes" {
	user "dodaj funkcje"; edit "$R/code.sh"
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"bats tests/"* ]]
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "dodaj funkcje"; edit "$R/code.sh"; bash_ t1 "bats tests/"; result t1 false
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "test_gate: no tests in the repo, or a bug turn, is not its business" {
	git -C "$R" rm -rq tests && git -C "$R" commit -qm x
	user "dodaj funkcje"; edit "$R/code.sh"
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; mkdir -p "$R/tests"; touch "$R/tests/a.bats"
	user "fix it"; edit "$R/code.sh"
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "caveman_gate: an opener or a closer is handed back once, a plain answer passes" {
	user "ile to"; say "Sure! It is 4. Let me know if you need more."
	run "$H/caveman_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"opener and a closer"* ]]
	run "$H/caveman_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "ile to"; say "4."
	run "$H/caveman_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "tokenlimitgate: the limit text sets the mark and the Stop gates stand down" {
	user "napraw to"; edit "$R/code.sh"
	run "$H/tokenlimitgate" < <(ev)
	[ "$status" -eq 0 ]
	[ ! -e "$SESSION_GATE_DIR/limit.s1" ]
	say "Claude usage limit reached. Resets at 5pm."
	run "$H/tokenlimitgate" < <(ev)
	[ "$status" -eq 0 ]
	[[ $output == *"stand down"* ]]
	[ -e "$SESSION_GATE_DIR/limit.s1" ]
	run "$H/debug_gate" < <(ev)
	[ "$status" -eq 0 ]
	run "$H/test_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "updatedocsgate: a new file the README does not name is handed back once" {
	echo '# proj' > "$R/README.md"; git -C "$R" add README.md && git -C "$R" commit -qm readme
	printf '#!/bin/sh\n' > "$R/newtool"
	user "dodaj narzedzie"; edit "$R/newtool"
	run "$H/updatedocsgate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"newtool - not in README.md"* ]]
	run "$H/updatedocsgate" < <(ev)
	[ "$status" -eq 0 ]
	rm -rf "$SESSION_GATE_DIR"; echo '- `newtool` - does a thing' >> "$R/README.md"
	run "$H/updatedocsgate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "updatedocsgate: an edited file that was already there is not asked about" {
	echo '# proj' > "$R/README.md"; git -C "$R" add README.md && git -C "$R" commit -qm readme
	user "zmien"; edit "$R/code.sh"
	run "$H/updatedocsgate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "leanctx_gate: a big whole-file Read is refused once, a ranged or small one passes" {
	head -c 70000 /dev/zero | tr '\0' 'a' > "$T/big.txt"; echo small > "$T/small.txt"
	run "$H/leanctx_gate" < <(pre Read "$(jq -cn --arg f "$T/big.txt" '{file_path: $f, offset: 10, limit: 20}')")
	[ "$status" -eq 0 ]
	run "$H/leanctx_gate" < <(pre Read "$(jq -cn --arg f "$T/small.txt" '{file_path: $f}')")
	[ "$status" -eq 0 ]
	run "$H/leanctx_gate" < <(pre Read "$(jq -cn --arg f "$T/big.txt" '{file_path: $f}')")
	[ "$status" -eq 2 ]
	[[ $output == *"offset and limit"* ]]
	run "$H/leanctx_gate" < <(pre Read "$(jq -cn --arg f "$T/big.txt" '{file_path: $f}')")
	[ "$status" -eq 0 ]
}

@test "ponytail_gate: a new dependency and a new utils file are refused once, other edits pass" {
	echo '{"name": "x", "dependencies": {}}' > "$R/package.json"
	run "$H/ponytail_gate" < <(pre Edit "$(jq -cn --arg f "$R/package.json" '{file_path: $f, old_string: "{}", new_string: "{\"left-pad\": \"^1.3.0\"}"}')")
	[ "$status" -eq 2 ]
	[[ $output == *left-pad* ]]
	run "$H/ponytail_gate" < <(pre Edit "$(jq -cn --arg f "$R/package.json" '{file_path: $f, old_string: "{}", new_string: "{\"left-pad\": \"^1.3.0\"}"}')")
	[ "$status" -eq 0 ]
	run "$H/ponytail_gate" < <(pre Edit "$(jq -cn --arg f "$R/package.json" '{file_path: $f, old_string: "\"x\"", new_string: "\"y\""}')")
	[ "$status" -eq 0 ]
	run "$H/ponytail_gate" < <(pre Write "$(jq -cn --arg f "$R/utils.py" '{file_path: $f, content: "x"}')")
	[ "$status" -eq 2 ]
	[[ $output == *"abstraction"* ]]
	run "$H/ponytail_gate" < <(pre Write "$(jq -cn --arg f "$R/parse.py" '{file_path: $f, content: "x"}')")
	[ "$status" -eq 0 ]
}

@test "graphify_gate: a repo with a fresh graph gets the first search refused, once" {
	run "$H/graphify_gate" < <(pre Grep '{"pattern": "x"}')
	[ "$status" -eq 0 ]
	mkdir -p "$GRAPHIFY_HOME/proj" && echo '{}' > "$GRAPHIFY_HOME/proj/graph.json"
	run "$H/graphify_gate" < <(pre Grep '{"pattern": "x"}')
	[ "$status" -eq 2 ]
	[[ $output == *mcp__graphify__query_graph* ]]
	run "$H/graphify_gate" < <(pre Grep '{"pattern": "x"}')
	[ "$status" -eq 0 ]
	rm -rf "$SESSION_GATE_DIR"; touch -d '90 days ago' "$GRAPHIFY_HOME/proj/graph.json"
	run "$H/graphify_gate" < <(pre Grep '{"pattern": "x"}')
	[ "$status" -eq 0 ]
}

@test "mybashtoolgate: a long command run before is refused once, short or varied ones are not" {
	long='cd /somewhere && grep -rn "pattern" src | sort | uniq -c | sort -rn | head -20 > /tmp/out-1.txt'
	bash_ b1 "$long"; bash_ b2 "${long//1/2}"
	run "$H/mybashtoolgate" < <(pre Bash "$(jq -cn --arg c "$long" '{command: $c}')")
	[ "$status" -eq 2 ]
	[[ $output == *"A repeated action becomes a script"* ]]
	run "$H/mybashtoolgate" < <(pre Bash "$(jq -cn --arg c "$long" '{command: $c}')")
	[ "$status" -eq 0 ]
	run "$H/mybashtoolgate" < <(pre Bash '{"command": "ls"}')
	[ "$status" -eq 0 ]
	rm -rf "$SESSION_GATE_DIR"
	run "$H/mybashtoolgate" < <(pre Bash '{"command": "echo a | sort | uniq | head -3 | wc -l | tr a b | cat -n | rev"}')
	[ "$status" -eq 0 ]
}

@test "readmegate: over 100 lines or an xD is refused, a short clean README and other files pass" {
	long=$(seq 1 120)
	run "$H/readmegate" < <(pre Write "$(jq -cn --arg f "$R/README.md" --arg c "$long" '{file_path: $f, content: $c}')")
	[ "$status" -eq 2 ]
	[[ $output == *"120 lines"* ]]
	run "$H/readmegate" < <(pre Write "$(jq -cn --arg f "$R/README.md" '{file_path: $f, content: "# x\nthis works XD\n"}')")
	[ "$status" -eq 2 ]
	[[ $output == *xD* ]]
	run "$H/readmegate" < <(pre Write "$(jq -cn --arg f "$R/README.md" '{file_path: $f, content: "# x\nthis works\n"}')")
	[ "$status" -eq 0 ]
	run "$H/readmegate" < <(pre Write "$(jq -cn --arg f "$R/todo.md" --arg c "$long xD" '{file_path: $f, content: $c}')")
	[ "$status" -eq 0 ]
	seq 1 130 > "$R/README.md"
	run "$H/readmegate" < <(pre Edit "$(jq -cn --arg f "$R/README.md" '{file_path: $f, old_string: "1\n2\n3", new_string: "1"}')")
	[ "$status" -eq 0 ]
}

@test "publish_gate: a push from a repo without LICENSE or with the login name is refused, a clean one passes" {
	push='{"command": "git push origin main"}'
	run "$H/publish_gate" < <(pre Bash '{"command": "git status"}')
	[ "$status" -eq 0 ]
	export PUBLISH_GATE_TESTS=0
	run "$H/publish_gate" < <(pre Bash "$push")
	[ "$status" -eq 2 ]
	[[ $output == *"no LICENSE"* ]]
	[[ $output == *"no README"* ]]
	echo '# proj' > "$R/README.md"; echo MIT > "$R/LICENSE"
	echo "path /home/$(id -un)/x" > "$R/notes"; git -C "$R" add . && git -C "$R" commit -qm c
	run "$H/publish_gate" < <(pre Bash "$push")
	[ "$status" -eq 2 ]
	[[ $output == *"home folder"* ]]
	git -C "$R" rm -qf notes && git -C "$R" commit -qm d
	run "$H/publish_gate" < <(pre Bash "$push")
	[ "$status" -eq 0 ]
}

@test "publish_gate: tests that fail refuse the push; a private backup remote is not checked" {
	echo '# proj' > "$R/README.md"; echo MIT > "$R/LICENSE"
	printf '#!/bin/sh\nexit 1\n' > "$R/check"; chmod +x "$R/check"; git -C "$R" add . && git -C "$R" commit -qm c
	run "$H/publish_gate" < <(pre Bash '{"command": "git push"}')
	[ "$status" -eq 2 ]
	[[ $output == *"tests fail"* ]]
	git -C "$R" remote add origin git@github.com:someone/private-backup.git
	PUSH_GATE_ALLOW=someone/private-backup run "$H/publish_gate" < <(pre Bash '{"command": "git push"}')
	[ "$status" -eq 0 ]
}

@test "knowsunknown_gate: a success claim after an edit with nothing run, and a path that does not exist, once" {
	user "dodaj funkcje"; edit "$R/code.sh"; say "Gotowe, działa. Plik jest w /home/nope-x/zzz/file.c i w $R/code.sh."
	run "$H/knowsunknown_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"nothing was run"* ]]
	[[ $output == *"/home/nope-x/zzz/file.c"* ]]
	[[ $output != *"$R/code.sh -"* ]]
	run "$H/knowsunknown_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "knowsunknown_gate: a run after the edit, urls and real paths pass" {
	user "dodaj funkcje"; edit "$R/code.sh"; bash_ b1 "./code.sh"; result b1 false
	say "Works, see https://github.com/x/y/blob/main/a.c and $R/code.sh."
	run "$H/knowsunknown_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "evolve_gate: his own script failed and was left, once; fixed, or written to issues.md, passes" {
	printf '#!/bin/sh\nexit 1\n' > "$R/tool"; chmod +x "$R/tool"
	user "uruchom"; bash_ b1 "$R/tool"; result b1 true
	run "$H/evolve_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"$R/tool"* ]]
	run "$H/evolve_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "uruchom"; bash_ b1 "$R/tool"; result b1 true; edit "$R/tool"
	run "$H/evolve_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "uruchom"; bash_ b1 "$R/tool"; result b1 true; edit "$R/issues.md"
	run "$H/evolve_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "evolve_gate: a failing system command or a red test is not a broken tool" {
	user "uruchom"; bash_ b1 "grep nothing /dev/null"; result b1 true; bash_ b2 "bats tests/"; result b2 true
	run "$H/evolve_gate" < <(ev)
	[ "$status" -eq 0 ]
}

@test "karpathy_gate: an edit before any plan is refused once, a plan lets it through" {
	user "zrob to"
	run "$H/karpathy_gate" < <(pre Edit "{\"file_path\": \"$R/code.sh\"}")
	[ "$status" -eq 2 ]
	[[ $output == *"assumptions and plan"* ]]
	run "$H/karpathy_gate" < <(pre Edit "{\"file_path\": \"$R/code.sh\"}")
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "zrob to"; say "Assumption: the script is POSIX. Plan: change one line in code.sh only."
	run "$H/karpathy_gate" < <(pre Edit "{\"file_path\": \"$R/code.sh\"}")
	[ "$status" -eq 0 ]
}

@test "karpathy_gate: Write over an existing code file is refused once; a new file and a doc are not" {
	user "zrob to"; say "Plan: small change."
	run "$H/karpathy_gate" < <(pre Write "{\"file_path\": \"$R/code.sh\"}")
	[ "$status" -eq 2 ]
	[[ $output == *"use Edit"* ]]
	run "$H/karpathy_gate" < <(pre Write "{\"file_path\": \"$R/code.sh\"}")
	[ "$status" -eq 0 ]
	run "$H/karpathy_gate" < <(pre Write "{\"file_path\": \"$R/new.sh\"}")
	[ "$status" -eq 0 ]
	run "$H/karpathy_gate" < <(pre Write "{\"file_path\": \"$R/NOTES.md\"}")
	[ "$status" -eq 0 ]
}

@test "karpathy_gate: Stop after an edit needs a named success criterion, once" {
	user "zrob to"; edit "$R/code.sh"; say "Done."
	run "$H/karpathy_gate" < <(ev)
	[ "$status" -eq 2 ]
	[[ $output == *"success criterion"* ]]
	run "$H/karpathy_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "zrob to"; edit "$R/code.sh"; say "Criterion: bats tests/ passes - 12 passed."
	run "$H/karpathy_gate" < <(ev)
	[ "$status" -eq 0 ]
	: > "$T/tr.jsonl"; rm -rf "$SESSION_GATE_DIR"
	user "co to robi"; say "It lists files."
	run "$H/karpathy_gate" < <(ev)
	[ "$status" -eq 0 ]
}
