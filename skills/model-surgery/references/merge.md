# Merging checkpoints

Merging combines weights of models that share one architecture and one starting point. It costs no training, and it
fails quietly when the models are not compatible.

## Preconditions (check all, or do not merge)

1. Same architecture and every tensor has the same name and shape in all models (`raw-weights`, step 3).
2. Same tokenizer and same `vocab_size`. Different vocabularies make the embedding rows mean different tokens.
3. The fine-tunes descend from the same base. Merging unrelated models gives noise. Task-vector methods need the base.
4. All in bf16 or fp32, never already-quantized files.

## Methods, formulas and when

Let θ be a flattened tensor, base θ0, fine-tunes θ1..θn, task vector τi = θi − θ0.

| method | formula | use |
|---|---|---|
| linear / soup | θ = Σ wi·θi, Σ wi = 1 | fine-tunes of one base from the same recipe |
| SLERP | θ = sin((1−t)Ω)/sinΩ·θa + sin(tΩ)/sinΩ·θb, Ω = angle between θa and θb | exactly two models, keeps norm better than linear |
| task arithmetic | θ = θ0 + λ·Σ τi | add abilities; λ about 0.3-1.0, tune it |
| TIES | trim each τi to its top-k% by magnitude (k about 20), elect a sign per parameter by summed mass, average only the values that agree with it | many models, reduces interference |
| DARE | drop each element of τi with probability p (0.5-0.9) and rescale the rest by 1/(1−p), then add to θ0 (alone or before TIES) | fine-tunes with small deltas |

## Steps with mergekit

1. `pip install mergekit` (venv). Models in local folders or repo ids.
2. Write `merge.yml`, for example TIES:
   ```yaml
   merge_method: ties
   base_model: ~/models/base
   models:
     - model: ~/models/ft-a
       parameters: {density: 0.5, weight: 0.5}
     - model: ~/models/ft-b
       parameters: {density: 0.5, weight: 0.5}
   parameters: {normalize: true}
   dtype: bfloat16
   ```
   SLERP uses `merge_method: slerp`, `parameters: {t: 0.5}`, two models, optionally `t` per layer range.
3. `mergekit-yaml merge.yml OUT_DIR --cuda` (omit `--cuda` for CPU; it streams tensor by tensor, so RAM stays small).
4. Copy the tokenizer and `generation_config.json` from the model whose chat format you want to keep (mergekit
   `tokenizer_source: base` does it).
5. Run the check in SKILL.md on OUT_DIR. A merge that scores below its best parent on the task is a failed merge:
   change the weights, density or method, do not ship it.
6. Quantize last ([quant](quant.md)).

## More methods (mergekit knows them; names UNSURE per version, read `mergekit-yaml --help` and its docs)

- `della` (DARE-like pruning with magnitude-aware drop probabilities), `dare_ties`, `breadcrumbs` (drops both tiny and huge deltas), `model_stock`, `passthrough` (stack layers of different models: a "frankenmerge", it changes the depth and usually needs healing), `nuslerp`.
- Search for the weights instead of guessing: `mergekit-evolve` ([extras](extras.md)).
- Look at what each fine-tune changed before choosing the method ([extras](extras.md), model diffing).

## mergoo: a mixture of experts built from several fine-tunes

Repo: github.com/Leeroo-AI/mergoo (`pip install mergoo`). Instead of averaging the weights it keeps each model's feed-forward
block as an *expert* and adds a router, so skills stay separate. Merges MoE (full experts), Mixture-of-Adapters (LoRA experts) and a layer-wise
mix. The model grows (all experts are stored) and the router has to be trained, so it only pays when the experts are genuinely different (code, maths, a language).

1. Experts must share the base architecture and tokenizer (same preconditions as above).
2. Compose (config keys and calls checked against the README on 2026-11-15; `model_type` also takes e.g. `mistral`; for LoRA experts name them `adapter_1`, ... and use `model_id`s of adapters):
   ```python
   import torch
   from mergoo.compose_experts import ComposeExperts
   config = {
       "model_type": "llama",
       "num_experts_per_tok": 2,
       "experts": [{"expert_name": "base_expert", "model_id": "~/models/base"},
                   {"expert_name": "code", "model_id": "~/models/ft-code"},
                   {"expert_name": "math", "model_id": "~/models/ft-math"}],
       "router_layers": ["gate_proj", "up_proj", "down_proj"],
   }
   merger = ComposeExperts(config, torch_dtype=torch.float16)
   merger.compose()
   merger.save_checkpoint("~/models/moe-out")
   ```
3. The router layers are **untrained: train them** on a mix of the experts' domains with an ordinary HF `Trainer`. Load the composed checkpoint through mergoo's own classes, e.g. `from mergoo.models.modeling_mistral import MistralForCausalLM; MistralForCausalLM.from_pretrained(path)` (README example for Mistral; use the `modeling_<family>` module for yours). A "weights not initialised" warning for the gate layers is expected.
4. Check: it must beat each parent on that parent's own task and not lose elsewhere, and report total parameters against active parameters per token. The check in [SKILL.md](../SKILL.md) applies, plus a per-domain score.
5. On a small machine: composing a 1.5B base with 2-3 experts means 3-4× the weights; it composes on CPU, but router training wants a bigger GPU. See also [split](split.md) (dense to MoE).

## omnimergekit

Repo: github.com/mann1x/omnimergekit (README read 2026-11-15; one author, fast-moving, run it on a small model first). It is a fork-flavoured alternative to mergekit. What the README lists: merge script `omnimergekit.py` with `--method dare_ties | omnimerge_v2 | dare_linear | task_arithmetic | della`, and `omnimerge_v2` features chosen with `--v2-features` (`obim`, `darex`, `emr`, `fisher`); a **competence-map pipeline** (`competence/competence_extract.py`, `competence_combine.py`) that measures per source model which weights mattered for the tasks it uniquely solved, fed in with `--fisher`; **expert pruning** for MoE models (`gemma4/expert_pruning/expert_drop.py`, a Qwen3.6-35B-A3B prune recipe); `scripts/quantize_gguf.py` for GGUF tiers on top of llama.cpp. Example from the README: `python omnimergekit.py --base $BASE --source $A --source $B --output merged/ --method omnimerge_v2 --v2-features fisher,darex --weights 0.35,0.40,0.25 --density 0.53 --darex-q 0.85 --fisher maps/a.safetensors,maps/b.safetensors --device cuda`; the math is in its `docs/METHOD_omnimerge_v2.md`. Use it when mergekit's methods lose to the best parent and you want the Fisher-based variants,
or for expert pruning ([extras](extras.md)). Same rules as everything here: pinned version in RECIPE.md, bf16 in, check out, original untouched. Because it is young, **compare its result with a plain mergekit TIES/DARE merge** of the same models: if it is not clearly better on your check, use the boring one.

## By hand (no dependency)

For each tensor name: load it from every model (memory-map the safetensors, one tensor at a time), compute the formula
in float32, cast to bf16, write into a new safetensors. Process tensors, not models, so memory is one tensor times n.
Known bugs from past implementations here: TIES sign election must use the sum with magnitudes, not a vote; DARE must
rescale; SLERP must fall back to linear when the vectors are nearly parallel (sinΩ about 0).
