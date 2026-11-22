# code (done)

An exit code of 0 means the process didn't crash, not that the feature works.

## Before reporting done

- Run the real thing end to end: the project's own `./run` / `./test` / `./check`, the command the user will type,
  the service's actual state and log, a screenshot of a GUI result.
- TUIs: drive them for real. In tmux (`tmux new -d -x 160 -y 45`, `send-keys`, `capture-pane -p`), or Python
  `os.openpty()` with an explicit window size (`fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols,
  0, 0))`; a zero size renders nothing), realistic key timing, ANSI stripped before comparing. This found a dropped
  keystroke in a ratatui TUI that no re-read of the code would have.
- Generated output: look at it. After pruning a model, generate real text and compare with the original ("lobotomy
  check"), not only sparsity and tokens per second; after a PDF render, open the page; after a config change, load it
  (`emacs --batch`, `bash -n`, `nginx -t`).
- A mathematical claim about the code (a bound, an equivalence, an invariant): a theorem in the project's `lean4/`
  that passes its axiom audit, not an argument in prose (`code (lean4)`).
- A suspiciously convenient PASS right after a refactor: check whether a skip path swallowed the failure (`code (test)`).
- His live sessions are not a test rig: his Godot editor, his browser, his Emacs. Use a disposable instance first.
- Anything visual on his Wayland desktop: a full-screen `grim` screenshot (or his `screenshot` tool) and, for motion,
  a few seconds of `wf-recorder`; reference and candidate as two images; keys with `wtype -k Right -k Return`. Look at
  what was captured for clipping, overlap, stale state and focus. Keep the PID of anything launched and stop exactly
  that process afterwards.

## Checking finished work (verify mode)

Turn the acceptance into the smallest proof set; reuse results still valid for the current state; focused checks
before wide ones; report pass / fail / unavailable / blocked exactly; no edits, polish or extra tests after the
criteria pass. Report the commands, their results and the open risk, nothing else.
