#!/usr/bin/env bats
# tools/claude-firefox with a fake flatpak that listens on a port like Firefox does: start, stop kills the real
# process (not only the wrapper), a taken port is refused, profile and flags are what the MCP needs.

setup() {
	T=$BATS_TEST_DIRNAME/../tools/claude-firefox
	export CLAUDE_FIREFOX_DIR=$BATS_TEST_TMPDIR/cf
	export CLAUDE_FIREFOX_PORT=$((20000 + RANDOM % 20000))
	mkdir -p "$BATS_TEST_TMPDIR/bin"
	cat > "$BATS_TEST_TMPDIR/bin/flatpak" <<'FAKE'
#!/usr/bin/env bash
# flatpak run APP args... : spawn a child (like bwrap -> firefox) that listens on the marionette port and outlives us
echo "$@" > "$CLAUDE_FIREFOX_DIR/args"
exec python3 -c 'import socket,sys,time
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(("127.0.0.1", int(sys.argv[1]))); s.listen(1); time.sleep(60)' "$CLAUDE_FIREFOX_PORT" --profile "$CLAUDE_FIREFOX_DIR/profile" --marionette
FAKE
	chmod +x "$BATS_TEST_TMPDIR/bin/flatpak"
	export PATH=$BATS_TEST_TMPDIR/bin:$PATH
}

teardown() { "$T" stop > /dev/null 2>&1 || true; }

@test "start brings the port up and status says running" {
	run "$T" start
	[ "$status" -eq 0 ]
	run "$T" status
	[ "$status" -eq 0 ]
	[[ $output == *"listening"* ]]
}

@test "start passes profile, marionette and the debugging port the MCP needs" {
	"$T" start
	run cat "$CLAUDE_FIREFOX_DIR/args"
	[[ $output == *"--profile $CLAUDE_FIREFOX_DIR/profile"* ]]
	[[ $output == *"--marionette"* ]]
	[[ $output == *"--remote-debugging-port 9222"* ]]
	[[ $output != *"--headless"* ]]
}

@test "CLAUDE_FIREFOX_HEADLESS adds --headless" {
	CLAUDE_FIREFOX_HEADLESS=1 "$T" start
	run cat "$CLAUDE_FIREFOX_DIR/args"
	[[ $output == *"--headless"* ]]
}

@test "stop ends the listening process and status says not running" {
	"$T" start
	run "$T" stop
	[ "$status" -eq 0 ]
	sleep 1
	run "$T" status
	[ "$status" -eq 1 ]
	[[ $output == *"not listening"* ]]
}

@test "a taken port is refused" {
	python3 -c 'import socket,sys,time
s=socket.socket(); s.bind(("127.0.0.1", int(sys.argv[1]))); s.listen(1); time.sleep(8)' "$CLAUDE_FIREFOX_PORT" &
	sleep 1
	run "$T" start
	kill %1 2> /dev/null || true
	[ "$status" -eq 1 ]
	[[ $output == *"already in use"* ]]
}

@test "stop when nothing runs exits 1" {
	run "$T" stop
	[ "$status" -eq 1 ]
}
