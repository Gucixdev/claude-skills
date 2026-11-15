# Splitting a model

"Split" means four different things. Pick the one you mean.

| you want | section |
|---|---|
| a file too big for one piece or one disk | 1. shards |
| a model bigger than VRAM, run part on GPU, part on CPU | 2. offload |
| a piece of the network (some layers, the head) as its own checkpoint | 3. by layers |
| a dense model turned into a mixture of experts | 4. dense to MoE |

## 1. Shards

- Hugging Face: `model.save_pretrained(dir, max_shard_size="2GB", safe_serialization=True)` writes `model-0000N-of-0000M.safetensors` plus `model.safetensors.index.json` (`weight_map`: tensor name to file). Never edit the weights without updating that index.
- Check every shard with `scripts/safetensors-header FILE` (header only, finds truncated files, fast on a slow disk).
- GGUF: `llama-gguf-split --split --split-max-size 2G in.gguf out-prefix` gives `out-prefix-00001-of-0000N.gguf`; loaders take the *first* file and find the rest. `--split-max-tensors N` splits by tensor count instead; `--merge first-file.gguf out.gguf` puts it back (flags checked against the llama.cpp tool README 2026-11-15).

## 2. Offload (more model than VRAM)

1. `scripts/vram-fit -m config.json -p PARAMS -b BITS -c CONTEXT` says if it fits, or prints the `-ngl N` (number of layers on the GPU) that does.
2. llama.cpp: `llama-server -m model.gguf -ngl N -c CTX`; the KV cache can be quantized too: `-ctk q8_0 -ctv q8_0` (allowed types include q8_0, q4_0, q5_0, iq4_nl; a quantized V cache needs flash attention on, UNSURE of the current default).
3. Two GPUs: `--tensor-split 3,1` is the ratio.
4. **MoE models**: keep attention and the shared layers on the GPU and the experts on the CPU: `-ot "exps=CPU"` (`-ot, --override-tensor <tensor name pattern>=<buffer type>`, checked in the llama-server README 2026-11-15). Expert weights are big but only a few are read per token, so CPU RAM bandwidth is enough; this is how a 30B+ MoE runs on 4 GB.
5. Measure with `llama-bench` at your real `-c`; a layer count that fits at 512 tokens can run out at 8k.
6. Run [gen-compare](../scripts/gen-compare) with the offloaded setup against the full-precision answers: offload must not change the output, only the speed.

## 3. By layers (a piece of the network as a checkpoint)

Tensor names carry the layer index: `model.layers.17.self_attn.q_proj.weight`. To cut layers a..b:

```python
from safetensors import safe_open
from safetensors.torch import save_file
import re, glob
keep = {}
for f in sorted(glob.glob("src/*.safetensors")):
    with safe_open(f, "pt") as s:                       # lazy: reads only what we ask for
        for k in s.keys():
            m = re.match(r"model\.layers\.(\d+)\.", k)
            if m and A <= int(m.group(1)) <= B:         # A, B: your range
                keep[re.sub(r"layers\.\d+", lambda x: f"layers.{int(m.group(1)) - A}", k, 1)] = s.get_tensor(k)
save_file(keep, "piece/model.safetensors", metadata={"format": "pt"})
```

Then write a `config.json` with `num_hidden_layers = B - A + 1`. The embedding (`model.embed_tokens`) and the final norm/head (`model.norm`, `lm_head`) are not in any layer: copy them where you need them. Uses: layer-wise comparison of two fine-tunes ([extras](extras.md) model diffing), pipeline split across two machines, testing one block in isolation. Verify by loading and running the piece on a hidden state recorded from the full model: the output must match.

Removing layers from the *middle* of a model to make it smaller is [prune](prune.md) (layer removal), not a split.

## 4. Dense to MoE (sparse upcycling)

1. Copy each dense MLP E times (E = 4 or 8) as experts and add a router (a linear layer, hidden size to E), initialised small/random. With identical experts the model starts out equal to the dense one.
2. Break the symmetry and train: the router and some of the experts must see data, or all experts stay the same and nothing is gained. Top-2 routing and a load-balancing loss are the usual defaults.
3. Alternative: **different experts from different fine-tunes** of one base (code, maths, chat): that is what mergoo does, see [merge](merge.md) (the MoE section). The router is trained, the experts are mostly frozen, so it fits on a small GPU for a small model.
4. Check: it must beat each single parent on the parent's own task or the extra size bought nothing; and measure the real cost (active parameters per token and total VRAM).
