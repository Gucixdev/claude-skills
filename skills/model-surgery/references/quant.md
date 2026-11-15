# Quantization (GGUF with llama.cpp)

Goal: a file that runs on a small GPU (4 GB) or on CPU, with the quality loss measured, not assumed.

## What fits

Rough GGUF sizes for an 8B model (measure with `ls -la`; they vary by architecture): Q8_0 8.5 GB, Q6_K 6.6, Q5_K_M 5.7,
Q4_K_M 4.9, IQ4_XS 4.4, Q3_K_M 4.0, Q3_K_S 3.7, IQ3_XS 3.5, IQ2_XS 2.6. VRAM must also hold the KV cache and about
300 MB of overhead, so 4 GB of VRAM means a file of about 3.3 GB with a short context. Anything larger: offload only
some layers (`-ngl N`), the rest runs on CPU (slower, works). Below 3 bits, reasoning models degrade fast: prefer a
smaller model at 4 bits over a bigger one at 2-3 bits.

## Steps

1. **Tools** (once): `git clone --depth 1 https://github.com/ggml-org/llama.cpp`, then
   `cmake -B build -DGGML_CUDA=OFF && cmake --build build --target llama-quantize llama-imatrix -j4`. CPU build is enough
   for quantizing. For the converter: `pip install -r requirements/requirements-convert_hf_to_gguf.txt` into a venv
   (torch CPU wheel, transformers, gguf, sentencepiece).
2. **Check the source** with [raw-weights](raw-weights.md) first: complete shards, stop token present.
3. **Convert to a lossless GGUF**: `python convert_hf_to_gguf.py MODEL_DIR --outtype bf16 --outfile model-bf16.gguf`.
   Needs RAM about the size of the model; check the printed tensor count against the architecture.
4. **Calibration text for the importance matrix** (imatrix): 100-500 KB of text *in the model's real domain*. For a Lean
   prover use Lean 4 source and proofs (this repo's `lean4/` and `Proven.lean`), not Wikipedia; a generic imatrix is the
   reason a quantized specialist loses the specialty.
5. **imatrix**: `llama-imatrix -m model-bf16.gguf -f calib.txt -o imatrix.dat` (add `-ngl 99` with a GPU; on CPU it takes
   tens of minutes for 8B).
6. **Quantize**: `llama-quantize --imatrix imatrix.dat model-bf16.gguf model-Q4_K_M.gguf Q4_K_M`. Make two or three types
   (for example Q4_K_M, IQ4_XS, Q3_K_M) so the next step has something to compare.
7. **Measure** with the check in SKILL.md, against the bf16 or the highest type you can run: perplexity
   (`llama-perplexity -m FILE -f heldout.txt`), then the task metric. For a prover, run a proof-search harness (ask the model for proofs, let Lean check them, count the accepted ones) on the same
   `goals.md` for each file and compare the proofs found.
8. **Run it**: `llama-cli -m FILE -ngl N -c 4096 -p ...`; raise N until VRAM is full, check `nvidia-smi`. Or in ollama:
   `Modelfile` with `FROM ./model-Q4_K_M.gguf`, the model's `TEMPLATE`, `PARAMETER stop ...`, then `ollama create NAME -f Modelfile`.
9. Keep the bf16 GGUF; write the RECIPE.md (llama.cpp commit, imatrix file, types).

## Other formats (GPU, more VRAM than a small box has)

- **GPTQ / AWQ**: need a GPU with enough memory to hold the model during calibration (AutoAWQ, llm-compressor);
  weights-only 4-bit; served by vLLM. Same steps in spirit: calibration set from the domain, quantize, measure.
- **bitsandbytes NF4**: loads a bf16 checkpoint in 4 bits on the fly (`load_in_4bit`), for QLoRA, not for shipping.
