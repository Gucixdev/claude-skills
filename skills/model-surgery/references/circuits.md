# Finding the circuit behind a behaviour

Use when a model fails in a specific, repeatable way (loops after the answer, copies the prompt, drops a symbol) and
you want to know which layers, heads or MLPs are responsible, instead of guessing.

## Setup

- A model small enough to run with caches: on a small machine a 0.5-1.7B model on CPU, or in fp16 on the GPU if it
  fits. Tools: TransformerLens or nnsight.
- A **metric** that is one number per prompt, for example the logit of the EOS token minus the logit of the token the
  model wrongly emits instead. Without a number there is nothing to localize.

## Steps (activation patching)

1. Build pairs of prompts that differ in one thing: a **clean** one where the model behaves (stops) and a
   **corrupted** one where it fails (loops). Same length, ideally one token different.
2. Run both and record the metric, and cache all activations (residual stream, attention heads, MLP outputs) for each.
3. **Patch**: run the corrupted prompt, but replace one component's activation at one position with the clean run's
   value. Record how far the metric moves toward the clean result. Do this for every layer, then for every head and MLP in
   the layers that mattered, then for each token position.
4. Components whose patch restores most of the metric are *sufficient-ish*. Confirm **necessity** with the reverse:
   in the clean run, ablate the component (zero, or the mean over many prompts) and see the metric fall.
5. For speed on larger models use attribution patching (a gradient-based first-order estimate of step 3), then verify the
   top candidates with real patching.
6. Read what the located heads attend to (attention patterns) and what the MLP writes (project onto the unembedding,
   the "logit lens") to name the mechanism, and write it down with the evidence.
7. **Repair** only after the circuit is confirmed: fix the cause if it is in the config/template, steer with an
   activation addition at that layer, or fine-tune only those components ([finetune](finetune.md)) and re-run the
   check in SKILL.md. Editing weights by hand needs the full before/after check; one patched circuit often has side
   effects elsewhere.

## Circuit breakers (a different thing)

"Circuit breakers" (Zou et al., 2024, "Improving Alignment and Robustness with Circuit Breakers") is a published
safety training method, not a way of finding faults: a LoRA fine-tune that reroutes the model's internal
representations on unwanted inputs away from where they were (a loss that pushes their cosine with the original toward
zero), while a retain loss keeps representations on normal inputs unchanged. It is described here so the name is not
confused with circuit *finding* above.

## Honest limits

A circuit found on 20 prompt pairs is a hypothesis about those pairs. Say how many pairs, the effect sizes, and what
was not tested. Mechanisms found in a 1B model do not transfer to an 8B by assumption.
