# rea (formats)

What: an undocumented file - a save game, a config blob, a database, a firmware image, a project file, a cache.
How: samples first, bytes second. The goal is a layout table that a parser can be written from, checked against every
sample on hand.

## 0. Is it already documented?

`file FILE`, then the magic against a list (below), then the format's name plus "format specification" in the project's
own docs or repo before any byte is read. Tracker modules, SQLite, ZIP, PNG, ELF, PE, TTF, SQLite WAL, protobuf
and MessagePack are all written down; rediscovering them is wasted rounds.

| First bytes | It is |
|---|---|
| `7f 45 4c 46` | ELF (`software`, `ghidra`) |
| `4d 5a` | DOS/PE executable, also .NET assemblies |
| `50 4b 03 04` | ZIP: also jar, apk, docx, xlsx, odt, epub, whl, godot export in some modes |
| `1f 8b` / `28 b5 2f fd` / `fd 37 7a 58 5a 00` / `42 5a 68` | gzip / zstd / xz / bzip2 |
| `89 50 4e 47` / `ff d8 ff` / `47 49 46 38` / `52 49 46 46 .. .. .. .. 57 45 42 50` | PNG / JPEG / GIF / WebP |
| `53 51 4c 69 74 65 20 66 6f 72 6d 61 74 20 33 00` | SQLite 3 (`sqlite3 FILE .schema`) |
| `25 50 44 46` | PDF |
| `47 44 50 43` | Godot .pck (`games`) |
| `6d 6f 7a 4c 7a 34 30 00` | Mozilla lz4 (`.jsonlz4`) |
| `0a 0d 0d 0a` | pcapng (`network`) |
| `4f 67 67 53` / `66 4c 61 43` / `49 44 33` | Ogg / FLAC / MP3 with ID3 |

Not in the table and no magic: a headerless dump, a raw struct array, or encrypted. High entropy everywhere
(`scripts/fieldscan` marks blocks above 7.5 bits per byte) means compressed or encrypted: find the decompressor
call in the program that wrote it, not the format.

## 1. Collect samples that differ on purpose

This is the step that decides how fast the rest goes.

- Make the program write the file in its smallest state (empty project, new save at the start).
- Change exactly one thing in the program, save under a new name, repeat. A volume slider from 10 to 77. One more
  item. A name one character longer. One checkbox.
- Keep the actions in `re/samples.md` next to the file names: `a.bin = default`, `b.bin = volume 77`. A sample with no
  recorded cause is a sample you cannot use.

## 2. Look at the whole shape first

```sh
scripts/fieldscan a.bin b.bin        # size, magic, where the size is stored, constant vs varying bytes, strings, entropy
hexdump -C -n 128 a.bin              # the header; xxd -s OFFSET -l 64 works too (package vim or tinyxxd)
cmp -l a.bin b.bin                   # offset, then both bytes in octal: the exact bytes that changed
strings -n 6 -td a.bin | head -40    # printable runs with decimal offsets
```

`cmp -l` offsets are 1-based; `fieldscan` and `hexdump` are 0-based. Write which one a note uses.

Read the picture:

- Same size, a few bytes differ: a fixed-layout struct. The differing offset is the field you changed. Its width is
  the length of the differing range (volume 10 to 77: one byte; 300 to 70000: three or four).
- A different size: a length-prefixed or variable record. Find where the size grew, and look just before that offset
  for a number equal to the length of what was added.
- A number near the top equal to the file size, to size minus the header, or to a later offset: a length or an offset
  table. `fieldscan` lists these. Follow offsets with `python3 -c` (below) and check they land on record starts.

## 3. Decode a field: the usual shapes

| Shape | How to recognise | Decode |
|---|---|---|
| Fixed ints | the same offset in every sample, small values | `struct.unpack_from('<I', d, off)` (`<` little, `>` big endian) |
| Float | 4 bytes like `00 00 80 3f` (1.0) | `struct.unpack_from('<f', d, off)` |
| Length-prefixed string | a small number, then that many printable bytes | read n, then `d[off+k:off+k+n]` (k = width of n) |
| NUL-terminated string | printable run ending in `00` | split on `\0` |
| String table + offsets | a block of NUL-separated strings, and ints that point into it | `d[table+off:].split(b'\0')[0]` |
| Varint (LEB128/protobuf) | bytes with the top bit set continue the number | low 7 bits of each byte, little-endian groups |
| TLV | repeating `type, length, value` with the length covering the value | walk it with a loop, print `type length` pairs |
| Flags | one byte or word where changing one checkbox flips one bit | `bin(x ^ y)` between two samples |
| Timestamp | 4 or 8 bytes around 1.7e9 (Unix seconds), 1.7e12 (ms), or 1.3e17 (Windows FILETIME) | `datetime.fromtimestamp(v)` and see if the date is plausible |
| Checksum | a 2 or 4 byte value that changes with any other change | try CRC-32 (`zlib.crc32`), CRC-32C, Adler-32 (`zlib.adler32`), sum of bytes, over the body with and without the header |
| Padding | runs of `00` or `ff` between aligned records | note the alignment (4, 8, 16) |

```python
import struct, zlib
d = open('a.bin', 'rb').read()
print(struct.unpack_from('<IHH', d, 4))            # the header fields as one tuple
print(hex(zlib.crc32(d[8:]) & 0xffffffff))         # compare with the 4 bytes you suspect
```

Records: find the record size as the distance between repeating magic or between the offsets in a table, then print
the file as rows of that size (`for i in range(0, len(d), N): print(d[i:i+N].hex(' '))`); columns that vary
the same way are one field.

## 4. Strings and compression inside

- `binwalk FILE` (or `binwalk -e`) finds embedded zlib, gzip, PNG, filesystems; check each hit before trusting it
  (short magics give false hits).
- A zlib stream starts `78 01`, `78 9c` or `78 da`; try `python3 -c 'import zlib,sys;print(zlib.decompress(open(sys.argv[1],"rb").read()[OFF:]))' FILE`.
  Raw deflate (no header): `zlib.decompressobj(-15)`.
- zstd and lz4 are installed (`zstd -d`, `lz4 -d`); a frame without the usual file header is a block: use a library.
- Text in an old code page: `iconv -f CP1250 -t UTF-8`; UTF-16 shows as `61 00 62 00`: `strings -el`.

## 5. Claim, test, record

Per field one line: offset, size, endianness, meaning, how many samples agree, what was changed to prove it. Then write
the parser first as a reader, then as a writer: `parse(write(x)) == x` and `write(parse(sample)) == sample` byte for
byte on every sample. A writer that reproduces the sample exactly is the strongest evidence a layout is right.
Unknown bytes stay in the model as `unknown[off:len]` and are copied through unchanged; a writer that drops them
corrupts files.

Result: `docs/FORMAT.md` (layout tables, the open questions) plus the parser, and the samples in the repo's test
folder if they hold nothing personal (`spec`, `publish-anything`).

## Tools

`hexdump`, `od`, `cmp`, `strings`, `file` are here; `binwalk`, `hexyl` (a hex viewer with colours), `yara` are in the
Arch repos, ImHex is in the AUR. ImHex's pattern language (`.hexpat`) turns a verified layout into a live
overlay: write the struct, load it on a sample, and every wrong field shows up as nonsense immediately. His
Firefox `export-bookmarks` decodes `.jsonlz4` from the spec with no lz4 dependency.
