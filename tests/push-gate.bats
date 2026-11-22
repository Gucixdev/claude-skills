#!/usr/bin/env bats
# hooks/push-gate

setup() { hook=$BATS_TEST_DIRNAME/../hooks/push-gate; }
fire() { jq -n --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}' | "$hook"; }

@test "plain pushes are refused with a reminder" {
	for c in 'git push' 'git push -q git@github.com:Gucixdev/bash.git HEAD:main' 'cd x && git push origin main' 'git -C repo push' 'gh pr create --fill' 'gh release create v1' 'gh repo delete foo --yes'; do
		run fire "$c"
		[ "$status" -eq 2 ] || { echo "not refused: $c"; false; }
		[[ $output == *push-gate* ]]
	done
}
@test "PUSH_OK=1 lets it through" {
	run fire 'PUSH_OK=1 git push origin main'
	[ "$status" -eq 0 ]
}
@test "a remote matching PUSH_GATE_ALLOW is always allowed" {
	PUSH_GATE_ALLOW=backup-repo.git run fire 'git push -q git@github.com:someone/backup-repo.git HEAD:main'
	[ "$status" -eq 0 ]
}
@test "reads and look-alikes pass" {
	for c in 'git fetch' 'git log --oneline' 'git status' 'gh pr view 3' 'gh repo view x' 'echo git push' 'grep -rn "git push" docs' 'git commit -m "no git push here"'; do
		run fire "$c"
		[ "$status" -eq 0 ] || { echo "wrongly refused: $c"; false; }
	done
}
@test "garbage input is ignored" {
	run bash -c "printf 'x' | '$hook'"
	[ "$status" -eq 0 ]
}
