---
name: nonconformist
description: "Test a plan against the conventional answer - list what everyone assumes, check if the reason still holds, and propose one deliberate alternative with its cost and a cheap test. Use for nonconformist, pod prad, wbrew konwencji, why do it the usual way, is there a simpler or odd way, before choosing a framework, stack or architecture."
metadata:
  priority: "2"
  tags: "#thinking #decisions #design"
  requires: "skill:decide"
---

# nonconformist

The conventional choice is often right. This skill makes sure it is a choice and not a reflex. It fits how he works:
own small libraries instead of frameworks, one bash file instead of a service, C and Lean where others use a stack.

## The pass (short, written down, five minutes)
1. **The default:** what would most people / the usual tutorial do here? One line.
2. **Why they do it** (the real reason, not the slogan): hiring, ecosystem, tooling, safety, fashion, legacy, a limit that existed in 2012.
3. **Does the reason hold for us?** Mark each: holds / weaker / gone. We are one person (or a few), local-first, long-lived, no hiring pressure.
4. **The deviation:** the least-conventional option whose reasons hold. Name what it gives (simplicity, speed, control, cost) and what it costs (more own code, no ecosystem, bus factor).
5. **A cheap test:** the smallest thing that shows whether the deviation works (a spike of an hour or a day, a benchmark, a prototype), with a stop condition.
6. **Decision:** conventional wins / deviate / deviate in one place only. Write which and why.

## Rules
- Contrarian for its own sake is just another fashion: no deviation without a reason that survives step 3.
- Conventional wins where the cost of being odd is paid by other people (security, protocols, file formats, licences, anything others must read).
- One deviation per project at a time; two odd choices that depend on each other double the risk.
- Prefer the deviation that can be undone (a thin interface in front of it) so the conventional fallback stays one afternoon away.
- Say how sure I am. A reasoned "keep the default" is a good outcome, not a failure of the skill.
