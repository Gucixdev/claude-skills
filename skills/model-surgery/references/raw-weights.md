# Reading raw weights and finding what is wrong

Most "the model is broken" reports are a config or tokenizer mismatch, not damaged weights. Check in this order;
stop at the first hit.

## 1. The files and the config

1. `ls -la` the folder; compare shard sizes with the repo listing. A truncated download is the commonest cause.
2. Read `config.json`: `architectures`, `hidden_size`, `num_hidden_layers`, `num_attention_heads`, `num_key_value_heads`,
   `vocab_size`, `rope_theta`, `max_position_embeddings`, `tie_word_embeddings`, `torch_dtype`.
3. Read `generation_config.json`, `tokenizer_config.json`, `special_tokens_map.json`.

## 2. Stop tokens and chat template (the usual cause of a model that never stops)

A model that loops after a correct answer almost always has a stop-token problem, not bad weights:

1. Find the EOS the model was trained to emit: `eos_token_id` in `generation_config.json` and `eos_token` in
   `tokenizer_config.json`. Chat models often end turns with `<|im_end|>` while the base `eos_token` is
   `<|endoftext|>`; a runtime that only watches the second one never stops.
2. Check that the id of that token exists: `tokenizer.convert_tokens_to_ids("<|im_end|>")` is not `None`/unk.
3. In the converted file (GGUF) read the metadata: `tokenizer.ggml.eos_token_id` and
   `tokenizer.chat_template` (`gguf-dump model.gguf | grep -E 'eos|template'`, from the `gguf` pip package). They must match
   step 1.
4. In ollama, the `Modelfile` needs `PARAMETER stop "<|im_end|>"` and a `TEMPLATE` equal to the model's chat template.
5. This is a hypothesis for any prover or chat model that "cannot stop": test it by adding the stop parameter before
   anything else.

## 3. The safetensors file by hand (no torch needed)

Format: 8 bytes little-endian unsigned = N, then N bytes of JSON, then the raw tensor data.

```python
import json, struct
f = open("model-00001-of-00004.safetensors", "rb")
n = struct.unpack("<Q", f.read(8))[0]
header = json.loads(f.read(n))        # {name: {"dtype","shape","data_offsets":[a,b]}, "__metadata__": {...}}
data_start = 8 + n                    # tensor bytes live at data_start + a .. data_start + b
```

Checks that need only the header:
- every tensor listed in `model.safetensors.index.json` exists in some shard;
- the sum of `prod(shape)` over all tensors equals the parameter count the model card states;
- `embed_tokens` rows == `vocab_size` in `config.json` == `len(tokenizer)` rounded to the model's padding; a mismatch
  makes the last tokens map to garbage rows;
- dtype is what you expect (BF16 vs F32 doubles the size).

## 4. Statistics per tensor (needs numpy; bf16 to float32 by shifting the 16 bits into the top of a uint32)

For every tensor record: count of NaN, count of Inf, mean, std, max abs, fraction of exact zeros, L2 norm.

1. Any NaN/Inf in a weight: the checkpoint is damaged, stop.
2. Compare each layer's norm and std with its neighbours of the same type (q/k/v/o/gate/up/down). A layer whose std is
   10x off or all zeros is the suspect.
3. Per-layer table sorted by max abs: LLMs have a few legitimate outlier channels (massive activations); a single
   huge value in a place no neighbour has one is not that.
4. Compare two checkpoints (base vs fine-tune, or before vs after surgery): per tensor, relative difference
   `||a-b|| / ||a||` and cosine. This shows exactly which layers a fine-tune changed (LoRA merges touch attention and MLP
   but not norms and embeddings; full fine-tunes touch everything).
5. Tied embeddings: if `tie_word_embeddings` is true there is no separate `lm_head` tensor; a converter that expects
   one fails or silently initialises it.

## 5. Report

List which of 1-4 was checked, the numbers, and the verdict: file damaged / config wrong / stop token wrong / weights
fine. Say what was not checked.
