#!/usr/bin/env bats
# hooks/secret-guard

setup() { hook=$BATS_TEST_DIRNAME/../hooks/secret-guard; }
write() { jq -n --arg p "$1" --arg c "$2" '{tool_name:"Write",tool_input:{file_path:$p,content:$c}}' | "$hook"; }
edit() { jq -n --arg p "$1" --arg c "$2" '{tool_name:"Edit",tool_input:{file_path:$p,old_string:"a",new_string:$c}}' | "$hook"; }
multi() { jq -n --arg p "$1" --arg c "$2" '{tool_name:"MultiEdit",tool_input:{file_path:$p,edits:[{old_string:"a",new_string:"b"},{old_string:"c",new_string:$c}]}}' | "$hook"; }

# the fake secrets are built here so this file itself holds no real-looking key
gh() { printf 'ghp_%s' "$(printf 'a1B2%.0s' {1..9})"; }
aws() { printf 'AKIA%s' ABCDEFGHIJKLMNOP; }
pk() { printf -- '-----BEGIN %s PRIVATE KEY-----' OPENSSH; }

@test "real-looking secrets are refused in Write, Edit and MultiEdit, and the value is never printed" {
	for t in "token=$(gh)" "k=$(aws)" "$(pk)"$'\nabc' "key: gsk_$(printf 'Ab1%.0s' {1..15})" "OPENAI=sk-$(printf 'Zq9%.0s' {1..12})" "hf_$(printf 'Kj3%.0s' {1..12})" "AIza$(printf 'Wx7%.0s' {1..12})-_"; do
		for f in write edit multi; do
			run $f /tmp/x.txt "$t"
			[ "$status" -eq 2 ] || { echo "not refused ($f): ${t:0:8}"; false; }
			[[ $output == *secret-guard* ]]
			[[ $output != *"${t:0:12}"* ]] || { echo "value echoed"; false; }
		done
	done
}
@test "the two secret stores are allowed" {
	run write /home/u/.secrets "TOKEN=$(gh)"
	[ "$status" -eq 0 ]
	run write /home/u/.config/openapi/keys.env "K=$(gh)"
	[ "$status" -eq 0 ]
}
@test "samples and ordinary text pass" {
	for t in "token=$(gh) # example" "fake: $(aws)" "GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" "ghp_ is the prefix" "sk-short" "use \$HF_TOKEN from the environment" "# hello"; do
		run write /tmp/x.txt "$t"
		[ "$status" -eq 0 ] || { echo "wrongly refused: $t"; false; }
	done
}
@test "a secret on a later line of a long text is found" {
	run write /tmp/x.txt "$(printf 'line\n%.0s' {1..50})$(gh)"
	[ "$status" -eq 2 ]
}
@test "other tools and garbage input are ignored" {
	run bash -c "printf 'x' | '$hook'"
	[ "$status" -eq 0 ]
	run bash -c "jq -n '{tool_name:\"Bash\",tool_input:{command:\"echo hi\"}}' | '$hook'"
	[ "$status" -eq 0 ]
}
