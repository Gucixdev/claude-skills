# conventions (readme)

## README

1. What it is, in one paragraph, for someone who has never seen it.
2. Install, build, run: copy-paste commands, each one run before it was written down (`rules (rtfm)`).
3. What it looks like: real output from a real run (the user's bash README shows `logcollector` and `sniff` output).
4. Principles and gotchas that are not visible in the code.
5. Status: what is tested, on what, and what is not ("follows the documented syntax, not run on a live system").
6. License.
Plain full sentences (`docs`); no "production-ready", "blazing fast" or namedropped influences; no
claim without proof next to it.

## Every standalone folder

A library, a tool or an addon that can be used alone has its own README: quick start, what's inside, how to extend
it, known limits. A new module doesn't skip it because it was built fast.
