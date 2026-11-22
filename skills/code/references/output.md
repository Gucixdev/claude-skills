# code (output)

Keep the full version on disk (`tee` to a file, keep the path) and show the decisive part: test runs -> counts plus
the failing names; a build or log -> the first decisive error and the lines around it; big JSON -> its shape first
(keys, types, lengths), then `jq` for the fields needed; JSONL -> counts and fields; quiet flags. Uniform JSON arrays
fed in as context read better as one header row plus rows. Tool-call arguments are never re-encoded.
