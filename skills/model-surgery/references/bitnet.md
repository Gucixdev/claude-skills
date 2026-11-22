# BitNet: ternary weights (1.58 bit)

Weights are only -1, 0 or +1 (log2(3) = 1.58 bits), activations 8-bit. The matrix product turns into additions and
subtractions, so memory and energy drop a lot; the price is training the model *for* it. Plain post-training rounding
of an ordinary model to ternary destroys it. Claims marked UNSURE are from memory. Checked against the microsoft/BitNet README on 2026-11-15: the model, the commands and the supported list below.

## What the layer does (BitLinear)

1. Normalise the input (RMSNorm / SubLN in front of every BitLinear), quantize it per token to int8: x_q = clip(round(x · 127 / max|x|), -128, 127).
2. Quantize the weight: γ = mean(|W|) (absmean), W_q = clip(round(W / γ), -1, 1).
3. y = (W_q · x_q) · γ · max|x| / 127.
4. Training keeps the **latent full-precision weights** and the optimiser updates those; the forward pass uses the
   quantized ones, the backward pass passes the gradient straight through the rounding (straight-through estimator, STE).
   So training memory is the same as a normal model's: ternary saves memory only at inference.

## Two routes

| route | cost | result |
|---|---|---|
| train from scratch, ternary from step 0 | pretraining budget (Microsoft's BitNet-b1.58-2B-4T: 4T tokens, released) | best quality for the size |
| convert an existing model | many billions of tokens (UNSURE exactly: the converted Llama-3 8B in BitNet's supported list is named `HF1BitLLM/Llama3-8B-1.58-100B-tokens`, i.e. 100B tokens) | a gap to the original that shrinks with more tokens |

**Not possible on this machine** (4 GB, Pascal, no bf16): conversion training needs the full latent weights plus
optimiser state. Rent a GPU with 24+ GB for a 1-2B model, or just *run* the released ternary model (below).

## Convert an existing model (rented GPU)

1. Pick a small dense model (1-2B). Run [raw-weights](raw-weights.md) on it and save the "before" outputs and perplexity ([SKILL.md](../SKILL.md) check).
2. Replace every `nn.Linear` in the blocks (not the embedding, not the output head) with a BitLinear that has an RMSNorm in front. Keep the original weights as the latent weights.
3. **Warm up the quantization**: blend, W_eff = (1-λ)·W + λ·W_q, ramping λ from 0 to 1 over the first few thousand steps. Jumping straight to ternary gives a loss spike the model rarely recovers from.
4. Train on a mix close to the original's (web, code, your domain) with the original model as the **teacher**: KL on logits plus the usual cross-entropy ([distill](distill.md)). Learning rate higher than usual for a ternary model (1e-3 range is reported, UNSURE), no weight decay on the latent weights toward zero beyond what the recipe says.
5. Watch the held-out loss against the original's. Stop when it flattens; the gap that remains is the cost of the conversion.
6. Export: store the ternary weights packed (2 bits each, plus one scale per tensor) in the format the runtime wants.

## Run a released ternary model (this machine, CPU)

1. `git clone --recursive https://github.com/microsoft/BitNet.git`, `pip install -r requirements.txt` (README); the project is `bitnet.cpp`, built on llama.cpp, with ternary kernels.
2. `huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T`, then `python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s` (quant types: `i2_s`, `tl1`). The 2.4B model was trained on 4T tokens.
3. `python run_inference.py -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf -p "You are a helpful assistant" -cnv`. Models it supports by name include Falcon3 1.58-bit (1B-10B) and the Llama3-8B conversion; from the bf16 weights there is `utils/convert-helper-bitnet.py`.
4. llama.cpp itself has ternary quant types `TQ1_0` and `TQ2_0` (UNSURE which build added them); they store ternary weights but do not have the speed kernels of bitnet.cpp.
5. Judge it by the check in SKILL.md, against a normal 4-bit model of similar size, on *your* prompts: the point of ternary is memory and CPU speed, not quality per parameter.

## Evidence against "just ternarise it"

omnimergekit's README records a negative result (`recipes/ternary_bonsai/`): training-free, PT2-style and QAT ternarisation of an ordinary 27B reached 43.3 % HumanEval against 70.1 % for a model trained ternary (Bonsai 2). Their ternary codecs (`PQ2_0`, `PTQ1_0`) say in the docs that they target ternary-*trained* weights and lose heavily on an ordinary model.

## Do not

- Do not "prune then ternarise" an already quantized model.
- Do not trust tok/s from a build that fell back to generic kernels: confirm the log shows the ternary kernel in use.
- Do not call a converted model "BitNet quality": it is a conversion, say how many tokens it saw.
