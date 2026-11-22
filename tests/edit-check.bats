#!/usr/bin/env bats
# hooks/edit-check: feed it the JSON Claude Code sends and look at the exit code and stderr.

setup() { hook=$BATS_TEST_DIRNAME/../hooks/edit-check; cd "$BATS_TEST_TMPDIR" || return; }
fire() { printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$1" | "$hook"; }

@test "a clean bash file passes silently" {
	printf '#!/usr/bin/env bash\necho hi\n' > ok.sh
	run fire "$PWD/ok.sh"
	[ "$status" -eq 0 ] && [ -z "$output" ]
}
@test "a bash syntax error is handed back, exit 2" {
	printf '#!/usr/bin/env bash\nif then\n' > bad.sh
	run fire "$PWD/bad.sh"
	[ "$status" -eq 2 ]
	[[ $output == *"bad.sh has problems"* ]]
}
@test "a shellcheck warning is handed back" {
	printf '#!/usr/bin/env bash\ncd /tmp\nls\n' > warn.sh
	run fire "$PWD/warn.sh"
	[ "$status" -eq 2 ]
	[[ $output == *SC2164* ]]
}
@test "extensionless file with a bash shebang is checked" {
	printf '#!/usr/bin/env bash\nif then\n' > tool
	run fire "$PWD/tool"
	[ "$status" -eq 2 ]
}
@test "python and json errors are caught, good ones pass" {
	printf 'def f(:\n' > bad.py; run fire "$PWD/bad.py"; [ "$status" -eq 2 ]
	printf 'x = 1\n' > ok.py; run fire "$PWD/ok.py"; [ "$status" -eq 0 ]
	printf '{"a":' > bad.json; run fire "$PWD/bad.json"; [ "$status" -eq 2 ]
	printf '{"a":1}' > ok.json; run fire "$PWD/ok.json"; [ "$status" -eq 0 ]
}
@test "c: a real error is caught, a missing header alone is ignored" {
	printf 'int main(void) { return x; }\n' > bad.c; run fire "$PWD/bad.c"; [ "$status" -eq 2 ]
	printf '#include "nowhere.h"\nint main(void) { return 0; }\n' > hdr.c; run fire "$PWD/hdr.c"; [ "$status" -eq 0 ]
}
@test "markdown, unknown extensions, missing files and references/ are skipped" {
	printf 'if then\n' > note.md; run fire "$PWD/note.md"; [ "$status" -eq 0 ]
	run fire "$PWD/nope.sh"; [ "$status" -eq 0 ]
	mkdir -p references/x; printf 'if then\n' > references/x/a.sh; run fire "$PWD/references/x/a.sh"; [ "$status" -eq 0 ]
}
@test "garbage input does not break the hook" {
	run bash -c "printf 'not json' | '$hook'"
	[ "$status" -eq 0 ]
}

@test "go and rust: syntax errors caught, unformatted but valid code passes" {
	printf 'package main\nfunc main( {\n' > bad.go; run fire "$PWD/bad.go"; [ "$status" -eq 2 ]
	printf 'package main\nfunc   main() {  }\n' > ok.go; run fire "$PWD/ok.go"; [ "$status" -eq 0 ]
	printf 'fn main( {\n' > bad.rs; run fire "$PWD/bad.rs"; [ "$status" -eq 2 ]
	printf 'fn   main() {  }\n' > ok.rs; run fire "$PWD/ok.rs"; [ "$status" -eq 0 ]
}
