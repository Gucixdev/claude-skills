"""Write a tiny valid .safetensors file: mkst.py OUT [truncate]. Two tensors: a F16 4x3 and an F32 5."""
import json, struct, sys
t = {"a.weight": ("F16", [4, 3], 24), "b.bias": ("F32", [5], 20)}
hdr, off = {"__metadata__": {"format": "pt"}}, 0
for k, (dt, sh, nb) in t.items():
    hdr[k] = {"dtype": dt, "shape": sh, "data_offsets": [off, off + nb]}; off += nb
h = json.dumps(hdr).encode()
blob = struct.pack("<Q", len(h)) + h + bytes(off)
if len(sys.argv) > 2:
    blob = blob[:-7]
open(sys.argv[1], "wb").write(blob)
