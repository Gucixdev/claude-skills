# Fine-tuning (LoRA / QLoRA, and expert iteration with a verifier)

## Can a small machine do it?

No for 8B. A 4 GB GPU cannot train an 8B even with QLoRA (weights alone are about 5 GB in 4 bits, plus
activations and optimizer). A 1.5-2B QLoRA is borderline with a short context and gradient checkpointing. Realistic
options: train a model of 1.5B or smaller locally, or rent a GPU with 16+ GB for the 8B and bring the adapter back
(adapters are tens of MB).

## LoRA steps

1. **Pick the base** and look at it with [raw-weights](raw-weights.md) (stop token, chat template).
2. **Data**: pairs in the model's *exact* chat template. Check 5 examples by eye, tokenized, that the template and the
   stop token are right at the end of every answer; a missing end token teaches the model never to stop.
3. **Loss mask**: compute the loss only on the answer tokens. Mask the prompt and the padding. Unmasked padding once made
   a base-dataset training diverge here.
4. **Hyperparameters to start from**: LoRA rank 16, alpha 32, dropout 0.05, on all linear layers (q,k,v,o,gate,up,down),
   learning rate 1e-4 to 2e-4 with cosine decay and 3% warmup, 1-3 epochs, effective batch 16-64 sequences. For QLoRA
   load the base in NF4 with double quantization, compute in bf16 (fp16 on cards without bf16 math, such as Pascal).
5. **Hold out** 5-10% of the data and a separate eval set; stop when the held-out loss rises.
6. **Merge the adapter** into the base in bf16 (`merge_and_unload()` in PEFT), save as safetensors, copy the tokenizer.
7. Check with SKILL.md; compare with the base on the *same* prompts. Then quantize ([quant](quant.md)).

## Expert iteration for a Lean prover (the verifier is free)

The Lean checker gives a perfect label, so the model can make its own training data:

1. Put many goals in `goals.md` (statements only).
2. Run a proof-search harness (ask the model for proofs, let Lean check them, count the accepted ones) with the model, with a high `TRIES` and temperature; every proof Lean accepts lands in
   `Proven.lean`. Wrong proofs cost nothing, they are simply not kept.
3. Turn each accepted (statement, proof) pair into a training example in the model's chat template.
4. Fine-tune with LoRA on those pairs, then repeat from step 2 with the better model and the goals it failed before.
5. Keep a fixed set of goals the model never trains on; its pass rate is the number to watch. If training pairs leak
   into it, the pass rate means nothing.
