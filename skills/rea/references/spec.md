# rea (spec)

What: the written result of a reverse-engineering session, and what is built from it. The spec is the part that stays
true when the code is replaced, so it is what the work is for.

Each finding is a claim with its evidence ("offset 0x10: u32 LE entry count - checked against 3 files"). Inferred vs.
checked stays labelled (`rules (knows-unknowns)`): a table with a "status" column - `checked`, `inferred`, `unknown` -
tells the next reader what to trust.

## Where it goes

| Target | File | Holds |
|---|---|---|
| a file format | `docs/FORMAT.md` | layout tables, field meanings, samples |
| a network protocol | `docs/PROTOCOL.md` | transport, framing, message table, state machine |
| a web/API | `docs/API.md` | endpoints, auth shape, examples |
| a program's behaviour | `docs/BEHAVIOUR.md` | files it uses, options, exit codes, the algorithm in words |
| a feel | `docs/VIBE.md` | the measured constants (`vibe`) |

Scratch work stays in `re/` (`lean`): samples, traces, captures, `NOTES.md`. `re/` is not published.

## FORMAT.md skeleton

```md
# NAME file format
Status: version 1 layout, checked on N samples (list). Byte order little endian unless stated.

## Header (offset 0, 16 bytes)
| Offset | Size | Type | Name | Meaning | Status |
|---|---|---|---|---|---|
| 0x00 | 4 | char[4] | magic | `HDR1` | checked (6 files) |
| 0x04 | 4 | u32 | size | total file size | checked |
| 0x08 | 2 | u16 | volume | 0-100, changed in the program from 10 to 77 | checked |
| 0x0a | 2 | - | - | always 00 00 | inferred (padding) |

## Records
Each record: ...; the table is at offset ..., N entries, each ... bytes.

## Open questions
- What 0x0c-0x0f hold: constant in all samples, nothing changed them.
```

## API.md / PROTOCOL.md skeleton

Per endpoint or message type: name, request (method, path, parameters / the bytes with offsets), response (shape or
bytes), one trimmed real example, errors seen, rate limit or timing. Then the auth or handshake, the pagination or
state machine, and the open questions. Invented values in examples, never real tokens, ids or addresses
(`publish-anything`).

## Check the spec with code

1. A reader for every sample you have: it reads each one without leftover bytes (`assert pos == len(data)`).
2. A writer: `write(read(sample)) == sample` byte for byte. Unknown fields are kept as raw bytes and written back.
3. A test per sample under `tests/`, run by the project's `./test` (`verify`). A sample that does not fit is a
   finding: the spec is wrong, not the sample.
4. For a protocol: a replay test against the real device or a recorded fake that answers with the captured replies.

## Then: rewrite, wrap or leave

- The GUI only drove a CLI or a file: wrap it - one bash file (`bash-everything`, `cli-everything`).
- You need the behaviour inside your own program: implement from the spec in the smallest fitting form (`code (ponytail)`),
  in the language the project already uses; no copied code, only the facts of the spec.
- Interoperability only: a converter or a client library, with the spec next to it as its documentation.
- A feel spec (`vibe`) goes into the constants of the user's own code (`ui (ui-designer)`).
Keep the spec next to the code and update it when a new sample disagrees. Commit the spec with the code that uses it
(`conventions (commits)`); `re/` raw material that holds personal data stays out (`publish-anything`).
