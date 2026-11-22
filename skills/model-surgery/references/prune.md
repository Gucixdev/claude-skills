# Pruning

First decide what you want: a smaller file, a faster run, or an interesting experiment. They are different and not
every method gives all three.

## The hardware fact that decides most of it

On this machine (Pascal GPU, no sparse tensor cores) **unstructured sparsity makes nothing faster**: zeros are still
multiplied. The 2:4 pattern speeds up only on Ampere and newer. What really shrinks and speeds up a model here is
**structured** pruning: whole layers, whole attention heads, narrower MLPs. Unstructured sparsity only helps a
compressed file (and a sparse-aware CPU kernel).

## Methods

1. **Layer removal** (cheapest, effective). For each layer compute Block Influence over a calibration set:
   BI = 1 − mean over tokens of cos(input hidden state, output hidden state). Layers with the lowest BI change the
   representation least. Remove the lowest few (start with 10% of layers), fix indices in `config.json`
   (`num_hidden_layers`) and rename the remaining tensors consecutively.
2. **Head or MLP-width pruning**: score each head or each intermediate neuron by its average output norm (or gradient
   times weight) on calibration data, remove the lowest, shrink the matching rows and columns of q/k/v/o and gate/up/down
   together. Update `num_attention_heads`/`intermediate_size`. Grouped-query models: remove whole KV groups.
3. **Magnitude pruning** (baseline): per tensor, zero the smallest |w| to a target sparsity. Simple, worst quality.
4. **Wanda**: score_ij = |W_ij| · ||X_j||₂, where X_j is input channel j over calibration tokens; within each output row
   zero the lowest scores. No retraining, needs only forward passes.
5. **SparseGPT**: layer-wise, solves for the weight updates that compensate the removed weights using the Hessian
   of the layer's inputs. Better than Wanda at high sparsity, much heavier.

## Steps

1. Calibration set: 128-512 sequences of the model's real domain (for a Lean prover, Lean source).
2. Run the check in SKILL.md on the original and save its outputs and metric (the "before").
3. Prune a copy, in bf16. Start small (10% layers or 30-50% sparsity) and look at the check before pushing further.
4. Run the check on the pruned copy. Compare generation, not just sparsity or tok/s.
5. **Heal** if the metric dropped: a short LoRA fine-tune on domain data ([finetune](finetune.md)), a few hundred steps.
6. Quantize ([quant](quant.md)). Sparse-then-quantize works; the reverse does not.
7. Record the removed layers or the sparsity pattern in RECIPE.md so it can be reproduced.
