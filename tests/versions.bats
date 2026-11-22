#!/usr/bin/env bats
# bin/versions and the two Claude Code hooks, in throwaway folders.

setup() {
	V=$BATS_TEST_DIRNAME/../bin/versions
	H=$BATS_TEST_DIRNAME/../hooks
	export VERSIONS_STORE=$BATS_TEST_TMPDIR/store
	W=$BATS_TEST_TMPDIR/work
	mkdir -p "$W"
}

hookjson() {	# hookjson TOOL KEY VALUE: the PreToolUse input Claude Code sends
	python3 -c 'import json, sys; print(json.dumps({"hook_event_name": "PreToolUse", "tool_name": sys.argv[1], "tool_input": {sys.argv[2]: sys.argv[3]}}))' "$@"
}

@test "snap: numbered copies in Emacs naming, unchanged content not stored twice, mtime kept" {
	echo one > "$W/a!b.txt"
	touch -d '2026-01-02 03:04:05' "$W/a!b.txt"
	"$V" snap "$W/a!b.txt"
	"$V" snap "$W/a!b.txt"
	echo two > "$W/a!b.txt"
	"$V" snap "$W/a!b.txt"
	base=$(realpath "$W/a!b.txt" | sed 's/!/!!/g; s|/|!|g')
	[ "$(cat "$VERSIONS_STORE/$base.~1~")" = one ]
	[ "$(cat "$VERSIONS_STORE/$base.~2~")" = two ]
	[ ! -e "$VERSIONS_STORE/$base.~3~" ]
	[ "$(stat -c %Y "$VERSIONS_STORE/$base.~1~")" = "$(date -d '2026-01-02 03:04:05' +%s)" ]
	[ "$(stat -c %a "$VERSIONS_STORE/$base.~1~")" = 600 ]
	run "$V" snap "$W/missing"
	[ "$status" -eq 0 ]
}

@test "ls, show, diff, restore: a restore stores the current content first" {
	echo one > "$W/f"; "$V" snap "$W/f"
	echo two > "$W/f"; "$V" snap "$W/f"
	echo three > "$W/f"
	run "$V" ls "$W/f"
	[ "${lines[0]%%$'\t'*}" = 2 ] && [ "${lines[1]%%$'\t'*}" = 1 ]
	run "$V" ls
	[[ "$output" == "$(realpath "$W/f")"$'\t'2$'\t'* ]]
	[ "$("$V" show "$W/f")" = two ] && [ "$("$V" show "$W/f" 1)" = one ]
	run "$V" diff "$W/f" 1
	[ "$status" -eq 0 ] && [[ "$output" == *"-one"*"+three"* ]]
	"$V" restore "$W/f" 1 2> /dev/null
	[ "$(cat "$W/f")" = one ]
	[ "$("$V" show "$W/f")" = three ]
	run "$V" show "$W/f" 9
	[ "$status" -ne 0 ]
}

@test "rewind: back to the content at a time, -n changes nothing, files untouched since stay" {
	echo old > "$W/a"; touch -d '2026-01-01 10:00' "$W/a"; "$V" snap "$W/a"
	echo new > "$W/a"; touch -d '2026-01-01 12:00' "$W/a"
	echo same > "$W/b"; touch -d '2026-01-01 09:00' "$W/b"; "$V" snap "$W/b"
	echo late > "$W/c"; touch -d '2026-01-01 11:30' "$W/c"; "$V" snap "$W/c"
	echo later > "$W/c"
	run "$V" rewind -n '2026-01-01 11:00' "$W"
	[[ "$output" == *"restore"$'\t'"$(realpath "$W/a")"* ]]
	[[ "$output" == *"skip"$'\t'"$(realpath "$W/c")"* ]]
	[[ "$output" != *"$W/b"* ]]
	[ "$(cat "$W/a")" = new ]
	"$V" rewind '2026-01-01 11:00' "$W" > /dev/null
	[ "$(cat "$W/a")" = old ] && [ "$(cat "$W/b")" = same ] && [ "$(cat "$W/c")" = later ]
}

@test "snap-before-edit hook: stores the file Claude is about to edit, never blocks" {
	echo before > "$W/edit.txt"
	run bash -c "hookjson() { $(declare -f hookjson | tail -n +2); }; hookjson Edit file_path '$W/edit.txt' | '$H/snap-before-edit'"
	[ "$status" -eq 0 ]
	[ "$("$V" show "$W/edit.txt")" = before ]
	run bash -c "echo '{}' | '$H/snap-before-edit'"
	[ "$status" -eq 0 ]
}

@test "no-rm hook: deleting commands are refused, everything else passes" {
	for cmd in 'rm -rf build' 'sudo rm x' 'cd x && rm -f y' 'ls | xargs -0 rm' 'find . -name "*.o" -delete' \
		'find . -exec rm {} +' 'git clean -fdx' 'git rm file' 'bash -c "rm x"' 'eval "rmdir d"' 'echo $(rm z)' \
		'unlink f' 'FOO=1 rm a' 'sudo -u root rm /etc/x' 'timeout 5 rm a' 'xargs -I{} rm {}' 'nice -n 5 shred f'; do
		run bash -c "printf '%s' \"\$1\" | '$H/no-rm'" _ "$(hookjson Bash command "$cmd")"
		[ "$status" -eq 2 ] || { echo "not refused: $cmd"; false; }
		[[ "$output" == *"trash"* ]]
	done
	for cmd in 'ls -la' 'echo "rm -rf /"' 'git rm --cached f' 'grep -rn rm src' 'trash old' 'mv a b' \
		'rm -rf /tmp/claude-x/build' "cat > f <<'X'"$'\n''rm -rf everything'$'\n''X' 'git commit -m "rm stale"'; do
		run bash -c "printf '%s' \"\$1\" | '$H/no-rm'" _ "$(hookjson Bash command "$cmd")"
		[ "$status" -eq 0 ] || { echo "refused: $cmd"; false; }
	done
}
