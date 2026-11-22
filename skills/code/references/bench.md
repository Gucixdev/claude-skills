# code (bench)

No number without a measurement; no measurement without a baseline (`rules (knows-unknowns)`).

## A run that counts

- Baseline and candidate on identical input, same machine, same build flags, back to back, alternating when the machine
  drifts. Warm up (caches, page cache, JIT), then at least 10 runs; report median, min and the spread, not one run.
- `hyperfine --warmup 3 -N 'old ARGS' 'new ARGS'` when installed; else `TIMEFORMAT=%R` and `time` in a loop, sorted
  with `sort -n`. Memory: `/usr/bin/time -v CMD` (Maximum resident set size). CPU detail: `perf stat -e
  cycles,instructions,cache-misses,branch-misses CMD`.
- Quality next to speed: a faster search with lower recall, a smaller model that writes nonsense, an encoder that
  produces wrong bytes - measure the output too (recall@k, a diff against golden output, a real generation after
  pruning).
- Noise: other load on the machine, thermal throttling on his laptop-class hardware, CPU governor (`cpupower
  frequency-info`); name it when it can't be removed.

## Before optimizing

Profile to find where the time goes: `perf record -g` and `perf report`, or explicit phase timers in the code (vecindex
was split into cluster probing, block scanning and re-scoring before touching any of them). Optimize the biggest
phase; re-measure all of them.

## Comparing with others

Standard datasets and methods so numbers mean something: ANN search on GloVe-100 with the ann-benchmarks method
(recall@10 against queries per second), against FAISS, Qdrant and turbovec on the same data and machine. State
versions and settings of the other tools.

## Write it down

Append every result to the project's log (`bench/RESULTS.md` or `docs/JOURNAL.md`): date, commit, machine (CPU, RAM,
GPU), command, numbers, one line of interpretation. Microbenchmarks in C: `clock_gettime(CLOCK_MONOTONIC)`, the result
fed to a volatile sink so the compiler can't drop the work. A change that didn't earn its place is reverted.
