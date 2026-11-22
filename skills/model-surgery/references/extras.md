# More techniques

Each section stands alone. Anything marked UNSURE is from memory: confirm against the paper or the tool's README before running.

## Model diffing (what did the fine-tune change?)

1. Open both checkpoints lazily (`safe_open`), per tensor name compute the relative change ‖θ1−θ0‖ / ‖θ0‖ and the cosine between θ1 and θ0, in float32, one tensor at a time.
2. Sum by layer and by kind (q/k/v/o, gate/up/down, embeddings, norms). A fine-tune that touched only a few layers or only the embeddings is visible at once; a delta that is ~0 everywhere means the "fine-tune" was a copy.
3. Rank of the change: SVD of Δ = θ1−θ0 for one matrix; if a few singular values carry most of the mass the change is low-rank and can be stored as a LoRA (`mergekit-extract-lora`, UNSURE of the name) at a fraction of the size.
4. Use it before a merge ([merge](merge.md)): two fine-tunes that changed the same layers fight, ones that changed different layers merge cleanly.

## Steering vectors (change behaviour without training)

1. Write 50-200 contrast pairs that differ in one trait only (a polite and a rude answer, a refusal and a compliance).
2. Run the model on both sides and record the hidden state at one layer (middle layers work best, scan layers), last token position.
3. The vector is mean(hidden of side A) − mean(hidden of side B), normalised.
4. At inference add `α · v` to the residual stream at that layer, α from 0.5 to 4; sweep it. Too high breaks the language.
5. Check with [SKILL.md](../SKILL.md): the trait moved *and* the unrelated prompts did not get worse. Related: [circuits](circuits.md) to find the layer.

## Vocabulary transplant (new tokenizer, or two models with different tokenizers)

1. For each token in the target vocabulary, tokenize its string with the *source* tokenizer; the new embedding is the mean of the source embeddings of those sub-tokens (Orthogonal Matching Pursuit is a better, slower option, UNSURE which tools ship it). Do input and output (`lm_head`) matrices separately unless tied.
2. Tokens that are identical in both vocabularies copy over exactly.
3. Resize `vocab_size`, fix EOS/BOS/pad ids and the chat template ([raw-weights](raw-weights.md)).
4. Short continued training (a LoRA that includes the embeddings) repairs the rest. Without it expect degraded text. This is also what makes logit distillation possible across tokenizers ([distill](distill.md)).

## Evolutionary / learned merging

- `mergekit-evolve` searches merge weights with CMA-ES against a task score (Sakana's evolutionary model merge idea). It needs a fast, honest scorer; on this machine that is only feasible for small models. Cost = (number of evaluations) × (merge + score).
- Other weight estimators: Fisher-weighted averaging, RegMean (closed form from activations), AdaMerging (learn coefficients on unlabeled data). They need calibration data and gradient or activation passes; use them when a plain TIES/DARE merge loses to its best parent.

## BitDelta and adapter composition (many fine-tunes, one base)

- **BitDelta** (Liu et al., 2024): store each fine-tune as the base plus a 1-bit sign matrix of the delta and one scale per matrix, then calibrate the scales by distillation. For serving many fine-tunes of one base at a fraction of the memory. Quality drop is task-dependent; run the check per fine-tune.
- **LoRA composition**: PEFT `add_weighted_adapter(adapters, weights, combination_type=...)` combines adapters (types include `linear`, `cat`, `svd`, `ties`, `dare_linear`, `dare_ties`; UNSURE of the full list in your version). Cheaper than merging full models; same interference problems as in [merge](merge.md).

## Speculative decoding heads (faster generation, same output)

- A small *draft* proposes several tokens, the big model verifies them in one pass; output is identical to normal sampling. llama.cpp can take a second small GGUF as the draft (`-md draft.gguf` / `--model-draft`; the old `--draft-max` is removed in current llama-server, use `--spec-draft-n-max`; checked 2026-11-15, read `--help` of your build); the draft must share the tokenizer.
- **Medusa / EAGLE** train extra heads on the frozen base model's hidden states to guess the next several tokens; training is cheap (the base is frozen) but the runtime must support them. Check the runtime first.
- Measure the **acceptance rate** and the real tokens/s; a draft that is rarely right is slower than none. Verify the outputs equal the plain run (greedy).

## Early exit and layer skipping

- First look, no training: apply the final norm and `lm_head` to the hidden state after each layer (logit lens) on your prompts. If the right token is already top-1 at layer 20 of 28 for easy tokens, an exit head is worth trying.
- Train a small exit head (or reuse the shared head) per exit layer on the frozen model; exit when the head's confidence passes a threshold; tune the threshold on held-out text so quality drops by less than your budget.
- Mixture-of-Depths (Raposo et al., 2024) routes tokens around blocks but is trained in, not bolted on. Runtimes like llama.cpp do not implement dynamic exit, so the speedup exists only in your own loop.

## Expert pruning (MoE)

1. Run the calibration set through the MoE model and count, per layer, how often each expert is chosen and how large its router weight is.
2. Remove the least-used experts (start with 10-25%): delete their tensors, delete the matching rows of the router matrix, set `num_experts` (and check `num_experts_per_tok` still fits) in `config.json`, renumber.
3. Heal with a short LoRA on domain data ([finetune](finetune.md)); some recipes weight experts by router weight times activation norm instead of a plain count (REAP, UNSURE of the details). omnimergekit has expert pruning built in ([merge](merge.md)).
4. Check per domain: the experts you removed may be the ones for rare tasks (a language, a language of code) that your calibration set did not contain.
