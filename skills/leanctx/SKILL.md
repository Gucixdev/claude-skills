---
name: leanctx
description: Say less, read less - short answers (answer first, exact payload, one idea per sentence), reads chosen by intent (search before whole files, outline before ranges, never re-read), command output shrunk before it lands in context, PR review comments, compressing a named prose file. Applies to every reply and every read.
metadata:
  priority: "0"
  tags: "#thirdparties #leanctx #context #tokens #reading #caveman #output #chat"
  requires: ""
---

# leanctx

The digest applies always; the parts have the detail.

## Always

- Answer first, without ceremony, with the exact payload (paths, commands, numbers), short words, one idea per
  sentence. Text that stays in a file is not chat: `conventions (docs)`.
- Read by intent: search before whole files, an outline before a range, the diff after an edit; batch independent
  lookups in one turn; never re-read what is already in context; point at code by path and line (`leanctx (leanctx)`).
- Big output goes to a file, then grep, count, head - only the decisive lines come back (`leanctx (output)`).
- Waiting, deferred tools and web reads: `leanctx (tools)`.

## Parts

Read the part when the task matches.

- [caveman](references/caveman.md) - Say less in chat - every reply answers first, without ceremony, with exact payload, short words and one idea per sentence; normal and ultra switch it. Applies to every reply; text that stays in files follows `conventions (docs)`, commit messages `conventions (commits)`. Parts in references/ - blocks (keep reusable scripts), compress (shrink a named prose file), review (PR review comments).
- [leanctx](references/leanctx.md) - Read less - pick the read by intent (search before whole files, outline before ranges, the diff after an edit), batch independent lookups in one turn, never re-read what is already in context, point at code by path and line. Applies to every file read and search; output is leanctx (output), waiting and tools leanctx (tools). Parts in references/ - output (shrink command output before it lands in context), tools (waiting, deferred tools, web reads).
- [output](references/output.md) - Shrink output before it lands in the context - the full output to a file, only the decisive part shown (failing test names, the first real error, the shape of JSON before its fields, counts for JSONL), quiet flags, uniform arrays as a header plus rows. Applies to every command run and tool result.
- [tools](references/tools.md) - Waiting and tools without waste - load deferred tools in one select call, never poll with sleep (background jobs with a completion notice, one bounded check), read the web from raw sources with an exact question. Applies to every tool load, long job and web fetch.
- [compress](references/compress.md) - Compress a prose file the user names (notes, memory, a long README section) - cut filler, hedging and connective fluff while keeping code, paths, numbers, headings and structure exact; the original goes to the trash first. Only when asked, only for a named file.
- [review](references/review.md) - Review comments to paste into a PR - one line per finding with its line, the problem and the fix, severity prefixes bug, risk, nit and q, no hedging or praise padding; a normal paragraph for security, architecture or a newcomer. Use when the user wants PR comments rather than a report.
