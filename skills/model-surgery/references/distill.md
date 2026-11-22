# Teaching a small model from a big one (distillation)

The student learns from a teacher instead of (only) from labels. Pick the kind by what you can reach from the teacher.

| what you get from the teacher | method |
|---|---|
| only text (API, ollama, a hosted model) | **sequence-level**: SFT on the teacher's answers |
| full logits, same tokenizer | **logit distillation**: KL to the teacher's distribution |
| text plus a way to judge it (Lean, tests, a checker) | **rejection sampling**: keep only verified answers ([finetune](finetune.md), expert iteration) |
| teacher can score the *student's* own samples | **on-policy distillation** (GKD) |

Before starting: the teacher's licence/terms must allow training on its output (many hosted models forbid it for building a competing model). Write it into RECIPE.md.

## Sequence-level (works across any pair of models)

1. Prompts: the real distribution of use, deduplicated, plus a held-out set the student never sees.
2. Generate with the teacher (greedy, or temperature 0.7 and 2-4 samples per prompt). Use `openapi ask` / the local server; write the prompt, answer and teacher id as JSONL.
3. **Filter**: drop empty, truncated (`finish_reason=length`), looping, wrong-language and refusal answers; if you have a checker, drop everything it rejects. Quality over quantity: a few thousand good pairs beat 100k noisy ones.
4. Format in the *student's* chat template with its stop token ([finetune](finetune.md) steps 2-3), loss on the answer only.
5. Train (LoRA first). Compare with the student before training and with the teacher, on the held-out prompts ([SKILL.md](../SKILL.md) check). The student reaching the teacher on your task, not on benchmarks, is the goal.

## Logit distillation (same vocabulary)

1. Loss per token: L = α·T²·KL(softmax(z_t/T) ‖ softmax(z_s/T)) + (1−α)·CE(labels), T = 1-2, α = 0.5-0.9. Use the same input tokens for both.
2. A full logit row is vocab-size wide (150k × sequence length is huge). Either run the teacher in the same step (needs the memory), or **precompute the top-k logits (k = 50-100) with their indices** and renormalise over them; store as fp16.
3. Different vocabularies: use sequence-level instead, or transplant the student's vocabulary first ([extras](extras.md)).
4. Optionally add a hidden-state loss (MSE between a student layer and a projected teacher layer) when the student is a *pruned copy* of the teacher: NVIDIA's Minitron recipe prunes depth/width and then recovers with logit distillation on a small fraction of the original data (UNSURE of the exact fraction); see [prune](prune.md).

## On-policy (GKD)

Training on the teacher's text has a mismatch: at inference the student continues from *its own* tokens. On-policy distillation
(Agarwal et al., 2023, *On-Policy Distillation of Language Models*) samples from the student, asks the teacher for its distribution on those
tokens and minimises a divergence (reverse KL or generalised JSD) **over the whole vocabulary at each position**, not only the sampled token.
TRL ships it as `trl.experimental.gkd.GKDTrainer` with `GKDConfig`: `lmbda` = fraction of on-policy (student-generated) batches (0 = supervised, 1 = fully on-policy), `seq_kd` = sequence-level KD on teacher outputs, `beta` = JSD interpolation (0 about forward KL, 1 about reverse KL); checked in TRL's docs 2026-11-15, the module path is under `experimental` so it may move. Needs teacher logits for every step, so teacher and student on the same machine or a precomputed cache; use it after sequence-level SFT has put the student near the teacher.

## Checks that catch the usual failures

- Student loss falls but the held-out score does not: it memorised; more diverse prompts, fewer epochs.
- Output got longer or never stops: the stop token was missing from the training text.
- The student copies the teacher's *mistakes* and its style tics ("As an AI..."): filter them out of the data.
- Never report the score on prompts that were in the training set.
