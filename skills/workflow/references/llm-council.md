# workflow (llm-council)

The pattern (upstream): stage 1, every model answers alone; stage 2, each one gets all the answers with the names
hidden and ranks them; stage 3, a chairman model writes the final answer. What it buys is independent errors - one
model's blind spot is caught by another. Seats on one model share their blind spots, so a council is only as good as
its spread.

## When

- Yes: a judgment with no single checkable answer (an architecture, a plan, which of three designs, whether an
  argument holds), a review where another pair of eyes matters, a question where I am at toss-up (`rules (calibration)`) and
  no check can settle it.
- No: a fact a command, the docs or the source can settle - check it (`rules (rtfm)`); models that learned from the same pages
  agreeing is not evidence. Routine work. Anything where the calls cost more than the decision is worth.
- He asks for it, or I offer it in one line, with the price, before a costly, hard-to-reverse decision. Never spun up
  unasked (`rules (discipline)`).

## Seats, most independent first

1. Other labs' models through the openrouter MCP: `send-message` is billed to the key the MCP minted (about 7 days,
   $10 cap by default) unless the model id ends in `:free` (rate-limited per account, and the free list rotates).
   `list-models`, `get-model` and `list-benchmarks` before choosing, and the expected cost said before the first call
   (`rules (zero-cost)`). Two to four strong models from different labs.
2. Local models, free: `ollama list` and `ollama run`, or llama.cpp's `llama-server` (OpenAI-compatible
   `/v1/chat/completions`). On the GTX 1050 Ti 4 GB only small models fit - a weak seat, useful as a critic, never the
   chairman.
3. Claude subagents on another model (the Agent tool's `model`, where offered), fresh context: they have not seen my
   reasoning, so they don't inherit my anchoring - but it is the same lab.
4. Last: role seats on one model - skeptic, minimalist (`code (ponytail)`), security, the user or client. Cheap and they
   catch some things, but they are not independent; say so.

The result says how independent the council was: "4 seats - 2 labs through OpenRouter, 1 local, me".

## Protocol

1. The brief, written once, the same text for every seat: the question, the context that matters (his constraints -
   C89, zero dependencies, zero cost - where they apply), what a good answer contains, a length cap. Saved as
   `council/DATE-TOPIC/brief.md` in a scratch folder, out of any shipped tree.
2. Answers: mine first, written to a file before I read any other - sealed. Every seat answers alone; no seat sees
   another.
3. Review: each seat gets all the answers labelled A, B, C..., in a different shuffled order per seat, with no model
   names, mine among them. Asked for the errors in each with the reason, what each missed, then a ranking. Names are
   hidden because models favour their own text and famous names; the order is shuffled because position biases a
   ranking.
4. Chairman: me by default, with that bias stated - or a seat from another lab when my own answer is the one in
   dispute. Written up: the answer; where all agreed; where they split, with the best argument on each side; a
   minority view kept when it has a real argument; the errors the review caught; what to check next. A vote count is
   never presented as truth: a disputed fact gets checked and the check reported.
5. Optional second round when stage 1 split: each seat sees the anonymized others and may revise once. A seat that
   flips without a new argument is herding, not evidence.

## Output and cost

Back to him: the decision, its level (`rules (calibration)`), the split and what is still missing - short. The raw answers
and reviews stay in `council/DATE-TOPIC/`, one file per seat, never pasted into the chat (`code (output)`). Each seat costs
two calls (answer and review); three seats are usually enough, and more add cost faster than insight.
