#!/usr/bin/env bats
# skills/model-surgery/scripts: safetensors-header, vram-fit, gen-compare (against a fake LLM server), quant-sweep (fake llama.cpp binaries).

setup() {
	S=$BATS_TEST_DIRNAME/../skills/model-surgery/scripts
	T=$S/tests
	W=$BATS_TEST_TMPDIR
}

@test "safetensors-header: lists tensors, summary, grep, and exit 0 on a clean file" {
	python3 "$T/mkst.py" "$W/ok.safetensors"
	run "$S/safetensors-header" "$W/ok.safetensors"
	[ "$status" -eq 0 ]
	[[ "$output" == *$'a.weight\tF16\t4x3\t12'* && "$output" == *$'b.bias\tF32\t5\t5'* ]]
	run "$S/safetensors-header" -s "$W/ok.safetensors"
	[[ "$output" == *"2 tensors"* && "$output" == *"dtype F16"* ]]
	run "$S/safetensors-header" -g bias "$W/ok.safetensors"
	[[ "$output" == *"b.bias"* && "$output" != *"a.weight"* ]]
}

@test "safetensors-header: a truncated file and a non-safetensors file exit 1 with the reason" {
	python3 "$T/mkst.py" "$W/cut.safetensors" x
	run "$S/safetensors-header" "$W/cut.safetensors"
	[ "$status" -eq 1 ] && [[ "$output" == *"truncated"* ]]
	echo "not a model at all, just text" > "$W/junk"
	run "$S/safetensors-header" "$W/junk"
	[ "$status" -eq 1 ] && [[ "$output" == *"not safetensors or truncated"* ]]
	run "$S/safetensors-header"
	[ "$status" -eq 2 ]
}

@test "vram-fit: fits, offload split, and the usage errors" {
	run "$S/vram-fit" -p 1.7 -b 4.85 -v 4 -l 28 -k 8 -d 128
	[ "$status" -eq 0 ] && [[ "$output" == *FITS* && "$output" == *"weights     0.96 GB"* ]]
	run "$S/vram-fit" -p 8 -b 4.85 -v 4 -c 8192 -l 36 -k 8 -d 128
	[ "$status" -eq 1 ] && [[ "$output" == *"-ngl 23 of 36 layers"* ]]
	run "$S/vram-fit" -p 8
	[ "$status" -eq 2 ]
	run "$S/vram-fit" -p 8 -b 4 -m "$W/missing.json"
	[ "$status" -eq 2 ]
}

@test "vram-fit: reads layers, KV heads and head size from a config.json" {
	echo '{"num_hidden_layers": 28, "num_key_value_heads": 8, "head_dim": 128}' > "$W/config.json"
	run "$S/vram-fit" -p 1.7 -b 4.85 -v 4 -m "$W/config.json"
	[ "$status" -eq 0 ] && [[ "$output" == *"KV cache    0.44 GB  (28 layers, 8 KV heads x 128"* ]]
}

@test "gen-compare: a loopy, non-stopping model is worse than a good one (exit 1); the same model twice is not" {
	python3 "$T/fake_llm.py" > "$W/port" &
	pid=$!
	for _ in 1 2 3 4 5 6 7 8 9 10; do [ -s "$W/port" ] && break; sleep 0.3; done
	port=$(head -1 "$W/port")
	printf 'prove one\n# skipped\n\nsay hi\\nthere\nthird\n' > "$W/prompts"
	run "$S/gen-compare" -p "$W/prompts" -o "$W/o1" -u "127.0.0.1:$port" good loopy
	st=$status
	run "$S/gen-compare" -p "$W/prompts" -o "$W/o2" -u "127.0.0.1:$port" good same
	st2=$status; out2=$output
	run "$S/gen-compare" -p "$W/prompts" -o "$W/o3" -u "127.0.0.1:$port" empty
	out3=$output
	kill "$pid"
	[ "$st" -eq 1 ]
	[ "$st2" -eq 0 ] && [[ "$out2" == *"identical answers: 3 of 3"* ]]
	[[ "$out3" == *"empty"* ]] && awk -F'\t' 'NR > 1 && $5 != 1 { exit 1 }' "$W/o3/summary.tsv"
	[ "$(awk -F'\t' 'NR > 1 && $6 == 1 && $4 == "false"' "$W/o1/summary.tsv" | wc -l)" -eq 3 ]
	[ "$(cat "$W/o1/good/002.txt" | wc -l)" -eq 2 ] || [[ "$(cat "$W/o1/good/002.txt")" == *"THERE"* ]]
}

@test "gen-compare: an unreachable server exits 2, missing prompts exit 2" {
	printf 'p\n' > "$W/prompts"
	run "$S/gen-compare" -p "$W/prompts" -o "$W/o" -u 127.0.0.1:1 m
	[ "$status" -eq 2 ] && [[ "$output" == *"server failed"* ]]
	run "$S/gen-compare" -p "$W/none" m
	[ "$status" -eq 2 ]
}

@test "quant-sweep: quantizes, measures, writes sweep.tsv; a failing type is marked FAIL and exits 1; no binaries exits 2" {
	head -c 2000000 /dev/zero | tr '\0' a > "$W/m.gguf"
	echo text > "$W/held.txt"
	LLAMA_BIN=$T/fakebin run "$S/quant-sweep" -f "$W/held.txt" -t "Q4_K_M Q3_K_S" "$W/m.gguf"
	[ "$status" -eq 0 ]
	[ "$(wc -l < "$W/sweep.tsv")" -eq 4 ] && grep -q '^source' "$W/sweep.tsv" && grep -q '^Q4_K_M' "$W/sweep.tsv"
	[ -s "$W/m-Q4_K_M.gguf" ]
	FAILQ=Q3_K_S LLAMA_BIN=$T/fakebin run "$S/quant-sweep" -S -f "$W/held.txt" -t "Q3_K_S" -o "$W/o" "$W/m.gguf"
	[ "$status" -eq 1 ] && grep -q $'Q3_K_S\t-\tFAIL' "$W/o/sweep.tsv"
	LLAMA_BIN=$T/fakebin run "$S/quant-sweep" -f "$W/held.txt" -i "$W/none.dat" "$W/m.gguf"
	[ "$status" -eq 2 ]
	PATH=/usr/bin:/bin LLAMA_BIN= run "$S/quant-sweep" -f "$W/held.txt" "$W/m.gguf"
	[ "$status" -eq 2 ] && [[ "$output" == *"not found"* ]]
}
