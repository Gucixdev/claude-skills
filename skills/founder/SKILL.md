---
name: founder
description: "Judge an idea, product or project like a panel of four founders - Gabe Newell, Linus Torvalds, Elon Musk, Steve Jobs - each asking the questions from their public way of working; ends in kill criteria, the cheapest experiment and a verdict. Use for founder, panel, jurorzy, czy to ma sens, ocena pomyslu, pitch, validate an idea, should I build this."
metadata:
  priority: "2"
  tags: "#thinking #business #decisions #review"
  requires: "skill:decide"
---

# founder

A panel of builders, not investors: nobody on it judges by "can this be sold on stage". The four are lenses built from how each is known to work in public (talks,
interviews, shipped products). Nothing here is a quote and nothing is said "by" them: write "Newell lens", never
"Gabe Newell says". If a lens would need a fact I do not have, it asks for it instead of inventing it.

## The four lenses
- **Newell (platform, customers, data):** who pays and why do they come back; is it a service problem or a product
  problem (piracy is a service problem); what does the community build on top; what do the numbers say, not the opinions;
  can it ship early and change in public.
- **Torvalds (technical taste, maintenance):** is the design simple enough to still be understood in ten years; where is
  the hype and where the working code; what is the boring part that must not break; who maintains it when the author
  is gone; does it stay compatible with what exists. Rejects anything over-engineered.
- **Musk (first principles, cost, scale):** what is the physical or arithmetic floor of the cost; which part can be deleted
  rather than optimised; is the target 10x or 10%; what is the timeline if nothing goes wrong, and the honest one if
  things do; what is the one constraint that decides everything.
- **Jobs (focus, experience, taste):** what is the one thing it does; what is said no to; who is it for, in one sentence;
  what does the first 30 seconds feel like; is the whole path end to end (not parts), and would he show it on stage.

## How a session runs
1. **Idea in one paragraph** (what, for whom, why now). Missing piece = ask once, or assume and say so.
2. Each lens: **3 questions**, then an answer from the facts at hand (repo, numbers, README), a **score 1-10**, one line why.
   Facts I do not have are marked `unknown`, not guessed.
3. **Kill criteria:** 2-3 measurable things that would end the idea, each with a number or a date.
4. **Cheapest experiment:** what can be done in a day or a week with no money that tells the most.
5. **Verdict:** build / change / drop, with the strongest reason for and against. Say how sure I am.

## Output (terse, no theater)
```
idea: <one line>
Newell  7  <why>      Q: ...
Torvalds 5 <why>      Q: ...
Musk    6  <why>      Q: ...
Jobs    8  <why>      Q: ...
kill if: ...
experiment: ...
verdict: <build|change|drop> - <reason>; sure: <low|medium|high>
```

## Rules
- Scores are not averaged into a magic number; disagreement between lenses is the information. Show it.
- Do not flatter. A weak idea gets the weak point first.
- For ideas that touch money, law or other people's data, add the question to `questions.md` ([[decide]]) instead of settling it.
- Pair with `nonconformist` (what everyone assumes here) and `economist` (who pays, what the incentives are).
