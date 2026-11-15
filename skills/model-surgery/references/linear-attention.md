# Linear attention and DeltaNet: converting a transformer

Softmax attention keeps a cache that grows with the context (KV cache) and costs O(n²) over a sequence. A linear
attention / state-space layer keeps a fixed-size state and costs O(n). Converting a trained model to it is attractive on a
small GPU (the KV cache is what eats 4 GB at long context). The price: weaker exact recall from far back.
LoLCATs checked against its README on 2026-11-15; other numbers marked UNSURE are from memory of the papers.

## The layers

- **Linear attention**: replace softmax(QKᵀ)V with φ(Q)(φ(K)ᵀV), φ a feature map; the state S = Σ φ(k)vᵀ is a matrix of fixed size per head.
- **DeltaNet**: the state is *edited* instead of only added to: S_t = S_{t-1}(I − β_t k_t k_tᵀ) + β_t v_t k_tᵀ (delta rule: overwrite what the key currently retrieves). Recalls better than plain linear attention.
- **Gated DeltaNet**: adds a decay gate on S (forgetting). Used in production hybrids, e.g. Qwen3-Next mixes it with ordinary attention layers (about 3 linear layers per 1 full-attention layer, UNSURE of exact ratio).
- Kernels live in the `flash-linear-attention` library (fla-org/flash-linear-attention); do not write the chunked scan by hand unless you must.

## Recipes (from the literature)

| recipe | what it does | cost |
|---|---|---|
| **LoLCATs** (HazyResearch/lolcats; *Low-rank Linear Conversion via Attention Transfer*) | 1. **attention transfer**: freeze the model, train only the new feature maps so each linear layer's output matches the softmax layer's output (MSE, layer by layer); 2. fix the remaining error with **LoRA** on the usual projections | tiny: tens of millions of tokens (UNSURE: the paper says about 0.04% of the pretraining tokens, 0.2% of parameters) |
| Mamba-in-the-Llama (distil into a Mamba hybrid) | init Mamba from the attention projections, keep some attention layers, distil with KL | billions of tokens at most, hybrids need fewer |
| SUPRA (uptrain into an RNN) | swap attention for a recurrent form, keep training | a few B tokens |
| hybrid by hand | convert only some layers and keep, say, every 4th as full attention | in between; the safest way to keep recall |

## Steps (LoLCATs-style, on a rented GPU; a 1-2B model first)

Its own repo does the whole thing in one command per model: `python distill_llama.py --model_config distill_llama3_8b_lk_smd_wtk64_fd64_w01 --finetune_config finetune_lora_qkvo_alpaca_clean ...` (configs in `configs/model/` and `configs/experiments/`; the README's LoRA stage uses a 50K-sample instruction set, Alpaca-clean). It supports Llama and Mistral 7-8B; Flash Attention 2 is needed to compute the softmax targets. Reading its configs is the fastest way to see the exact hyperparameters. The steps below are the same idea in your own code.

1. Teacher = the original model, untouched. Baseline: perplexity at 2k and at your longest context, plus a **needle-in-a-haystack** test (a fact placed at the start of a long text, ask for it) because recall is exactly what conversion breaks.
2. Choose layers to convert: all of them for max memory saving, or all except every 4th (hybrid). Start with the hybrid.
3. In each converted layer keep `q_proj/k_proj/v_proj/o_proj` as initialised from the teacher; add the feature map (small learnable per-head projection) and, for the delta variants, the β (and gate) projections.
4. **Attention transfer**: feed ~10-50M tokens of the model's domain, for each converted layer minimise MSE(linear_out, softmax_out) with everything but the new parameters frozen. Check the per-layer loss drops; a layer that stays high will hurt.
5. **LoRA recovery**: rank 8-16 LoRA on q,k,v,o (and MLP if needed), cross-entropy plus KL to the teacher on the same data ([distill](distill.md), [finetune](finetune.md)).
6. Evaluate: perplexity before/after, needle test at 2×, 4×, 8× the training length, generation check ([SKILL.md](../SKILL.md)). Linear layers can read *longer* than they trained on; confirm, do not assume.
7. Report the memory at your longest context: the KV cache is replaced by a fixed state, so measure real VRAM, do not compute it from the formula only.

## A small machine

Inference of a converted model fits easily (small state). Training does not: do steps 3-5 on a rented GPU and bring
back the weights. llama.cpp supports some ready-made linear/hybrid architectures (Mamba, RWKV, Qwen3-Next family, UNSURE which versions): a *new* converted
architecture will not load there until someone writes the graph. Check the architecture list in the runtime before you convert for it.
