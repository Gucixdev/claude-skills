# The biggest levers (small models, one 4 GB GPU)

Ranked by gain per hour of work on a small model. Each says when it pays, the first command, and how to see that it
worked (`gen-compare`, `quant-sweep` in `scripts/`; never trust the loss alone). Facts marked UNSURE were not read in
the docs this session. Flags move between releases: run `--help` of the build in front of you.

## 1. Test-time compute: sample more, pick with a check (no training)

Pays when the answer can be checked - code that runs, a Lean proof, a unit test, JSON that must parse, a math result.
- Best-of-N: sample N answers at temperature 0.7-1.0, keep the first that passes the verifier. For free-form
  answers with a short result, majority vote over N (self-consistency).
- A small model that solves a task 20% of the time at one try solves it far more often with 8-16 tries; the cost is
  time, not weights. Measure pass@1 against pass@N on the same prompts before anything else - if pass@N is no better,
  training will not fix it either (the model never produces the right answer).
- Run it on the llama-server: N parallel slots (`-np N`), one prompt each seed, a loop in bash plus the verifier.

## 2. Verifier-reward RL (GRPO / RLVR): train on what you can check

Pays when pass@N is much better than pass@1: the right answer exists in the model and RL pulls it up. It is the
cheaper cousin of expert iteration (`finetune`) and beats SFT on reasoning and code when a verifier exists.
- TRL: `GRPOTrainer` with `GRPOConfig`; `reward_funcs=[f1, f2]` (each takes completions, returns one float per
  completion; the rewards are summed); `num_generations` is the group size (8 is the default, 8-16 is typical);
  `beta` > 0 adds the KL term; `use_vllm=True` speeds generation; `loss_type="dr_grpo"` is the length-bias fix.
  Read the current GRPOConfig reference first, names move.
- Rewards: a hard check (tests pass, proof compiles) plus a small format reward; never a reward the model can
  satisfy without solving the task (reward hacking: print the expected output, empty-test files).
- On 4 GB: LoRA on a 0.5-1.5B model, short completions, group size 4-8. UNSURE how far it fits; if generation does
  not fit, generate with llama-server and run the update step separately (expert iteration is exactly that).
- Check: pass@1 on a held-out set before and after, plus `gen-compare` for loops and empty answers.

## 3. Per-tensor quantization: spend the bits where they hurt

Pays when a Q4 model is "almost fine": the loss sits in a few tensors.
- `llama-imatrix` on 100-300 samples of YOUR domain text, then `llama-quantize --imatrix FILE`.
- Raise the sensitive tensors: `--output-tensor-type q6_k`, `--token-embedding-type q6_k` (or q5_k), and
  `--tensor-type attn_v=q6_k` (regex, repeatable) - the output head, embeddings and attn_v are the usual ones.
- Lower the insensitive ones (`--tensor-type ffn_down=q3_k`) to pay for it; `quant-sweep` compares the result by
  perplexity and size. Model size against quality is a curve: pick the knee, not the smallest file.
- Check: perplexity on text of the real domain AND `gen-compare`, because perplexity hides a broken tool-call format.

## 4. Longer context without training

Pays when the task needs more than the trained window (long files, long logs).
- llama.cpp: `--rope-scaling yarn --rope-scale N --yarn-orig-ctx TRAINED_CTX` with `-c` = N x the trained context;
  YaRN has more knobs (`--yarn-ext-factor`, `--yarn-attn-factor`, `--yarn-beta-slow/fast`), leave them at defaults.
- KV memory is the real limit on 4 GB: `-ctk q8_0 -ctv q8_0` (the V cache quantized needs flash attention on; check
  `--help`) halves it.
- Check with a needle test: a fact planted at 25/50/75/100% of the window, asked at the end. Quality loss at the
  scaled length is normal; find where it starts instead of assuming.

## 5. Preference tuning without a reference model

Pays when SFT made the model correct but wordy, hedging or in the wrong style, and you can produce chosen/rejected
pairs (his corrections are exactly that).
- DPO needs a reference model in memory; ORPO and SimPO do not (one model, less VRAM). TRL has `DPOTrainer` and
  `ORPOTrainer`; SimPO is a loss of the CPO trainer (`CPOTrainer`, `loss_type="simpo"`) - UNSURE, check the docs.
- A few hundred clean pairs beat thousands of noisy ones. Same check as always: before/after `gen-compare`.

## 6. Already in other files (check there first)

- Combine fine-tunes of one base (model soup, TIES/DARE, mergoo): `merge`. Cut layers and heal with a short LoRA:
  `prune`. Draft-model or head speculative decoding (same output, faster): `extras`. Big model teaches small:
  `distill`. A trained adapter you can switch at run time: `extras` (BitDelta and adapter composition).

## Order to try

1. pass@N vs pass@1 (lever 1) - it tells which of the next steps can work. 2. Fix quantization (3) if the model is
fine at fp16 and worse at Q4. 3. RL or expert iteration (2) if pass@N >> pass@1. 4. Preference tuning (5) for style.
5. Context (4) only when a task really needs it.
