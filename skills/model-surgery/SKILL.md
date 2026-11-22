---
name: model-surgery
description: Recipes for model weights - raw safetensors/GGUF, quantizing (K-quants, imatrix, 4 GB VRAM), merging (SLERP, TIES, DARE), pruning, LoRA/QLoRA, distillation, BitNet, steering vectors, vocab transplant. Always ends in a before/after check. Use for quantize, merge, prune, finetune, LoRA, distill, GGUF, safetensors, surowe wagi, obwody.
metadata:
  priority: "2"
  tags: "#models #quantization #merge #prune #finetune #distill #bitnet #agents #circuits #weights #gguf #safetensors #llm"
  requires: "skill:code skill:rules cmd:python3 ?cmd:cmake"
---

# model-surgery

One skill, one file per technique under `references/`; read only the file for the job. Every recipe is numbered
steps with the command, because the point is to do it the same way twice.

| job | file |
|---|---|
| a model misbehaves (loops, wrong output, will not load) or you want to inspect it | [raw-weights](references/raw-weights.md) |
| make it smaller / fit the GPU | [quant](references/quant.md) |
| combine checkpoints | [merge](references/merge.md) |
| remove parts of it | [prune](references/prune.md) |
| teach it something | [finetune](references/finetune.md) |
| teach a small model from a big one (sequence-level, logits, on-policy) | [distill](references/distill.md) |
| ternary 1.58-bit weights, BitNet | [bitnet](references/bitnet.md) |
| replace softmax attention with linear / DeltaNet (long context on little VRAM) | [linear-attention](references/linear-attention.md) |
| shards, offload to CPU, cut layers out, dense to MoE | [split](references/split.md) |
| model diffing, steering vectors, vocab transplant, speculative heads, early exit, expert pruning, BitDelta | [extras](references/extras.md) |
| build an agent (loop, tools, limits), write an AGENTS.md, pick a framework | [agents](references/agents.md) |
| find which part of the network does a behaviour | [circuits](references/circuits.md) |
| which techniques pay most on a small model (best-of-N, GRPO, per-tensor quant, YaRN, SimPO/ORPO) and in what order | [levers](references/levers.md) |

## Scripts (`scripts/`, bash, `-h` prints the header)

| script | does |
|---|---|
| `safetensors-header FILE` | dtype/shape/offsets from the header only, flags truncation and gaps; `-s` sizes, `-g` group by layer |
| `vram-fit` | will it fit: weights + KV cache against VRAM, prints FITS or the `-ngl N` to use |
| `gen-compare` | same prompts through two or more models (ollama or llama-server, greedy), counts empty / no stop / loops, exit 1 if the last model is worse than the first |
| `quant-sweep` | llama-quantize + llama-perplexity over a list of types into `sweep.tsv`, resumable |

Tested with fakes (`scripts/tests/`, `tests/model-surgery.bats` in the repo); `quant-sweep` has not run against real llama.cpp binaries yet.

## Rules for every job

1. **Never touch the original.** Work on a copy or write to a new file; keep the source checkpoint and note its
   hash (`sha256sum`) and the exact config/commit it came from.
2. **Write the recipe down as you run it**: a `RECIPE.md` next to the output with the commands, tool versions and
   parameters. A model nobody can rebuild is a liability.
3. **Every surgery ends in the check** below. Sparsity, file size or tok/s alone prove nothing (a pruned model once
   looked fine in those numbers and could not generate).
4. **Merge and prune in bf16/fp32, quantize last.** Quantized weights cannot be merged or pruned meaningfully.
5. **Say what was measured and what was not**, with the numbers, in the report.

## The check (before and after, same inputs)

1. A fixed prompt set of at least 20 prompts that covers the model's real job, fixed seed or greedy decoding.
2. Generate before the surgery, save the outputs. Generate after, diff by eye on at least 5, and count failures:
   empty output, repetition loops, no stop token, gibberish, wrong language.
3. A number: perplexity on a held-out text of the same domain, or the task metric. For Lean provers the metric is
   free and exact: the proof pass rate of `symbiote/bin/freeworker (its own repo)` on a fixed `goals.md`, Lean as the judge.
4. **Termination**: confirm the model stops by itself (hits EOS) within the token limit on every prompt.
5. Accept only when the task metric did not drop more than the budget you set *before* starting.

## This machine

GTX 1050 Ti (Pascal, 4 GB VRAM, no tensor cores, no sparse 2:4), CPU for everything big. 8B models do not fit in
VRAM even at 4 bits; plan for partial offload or a smaller model. Downloads here are slow unauthenticated (about
0.5 MB/s per connection): use `aria2c -x16 -s16 -c`, which resumes. Keep models under `~/models/` (`/data` itself
is root-owned). Ollama is running; it takes GGUF files through a `Modelfile`.
