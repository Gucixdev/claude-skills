# rea (software)

What: a program on the user's machine - a CLI, a GUI app, a daemon, an installer - whose behaviour you need to know or copy.
How: climb from the cheapest question to the dearest one and stop when the spec line is written: docs, then what it
touches, then its code. Many questions end at rung 1.

## Pick the rung

| Question | First command | Rung |
|---|---|---|
| What does it do, which options | `PROG --help`, `man PROG`, the project's docs (`rules (rtfm)`) | 1 |
| Where does it keep its settings and data | `scripts/trace-summary -r PROG ...`, `inotifywait -m -r ~/.config` | 1 |
| What does it send over the network | `scripts/trace-summary -r PROG`, then `network` | 1 |
| What format is that file it writes | two samples, `formats` | 1 |
| What command does the GUI run underneath | `strace -f -e trace=execve -s 200 -o t.txt PROG`, then `rg execve t.txt` | 1 |
| How is a calculation or check done | static: names, strings, then Ghidra | 2 |
| What are the values at a moment | dynamic: gdb breakpoint, `ltrace`, a shim | 3 |

## 1. Black box: what it reads, writes and says

```sh
scripts/trace-summary -r PROG ARGS           # programs started, files written and read, connect() targets, ENOENT lookups
strace -f -tt -e trace=file,network,process -s 200 -o re/trace.txt PROG ARGS     # the raw log to grep afterwards
strace -f -e trace=write -e write=1,2 PROG   # the exact bytes it writes to stdout and stderr
touch re/mark; PROG ...; find ~ -newer re/mark -type f -not -path '*/.cache/*' 2>/dev/null     # files changed by one action
inotifywait -m -r -e modify,create,move ~/.config/APP                                # live, while you click
lsof -p PID; ls -l /proc/PID/fd; cat /proc/PID/environ | tr '\0' '\n'               # a running process: open files, environment
```

What it says on its own: `--verbose`, `-v`, `--debug`; environment switches such as `G_MESSAGES_DEBUG=all` (GTK/GLib),
`QT_LOGGING_RULES='*.debug=true'` (Qt), `RUST_LOG=debug`, `GODEBUG=...` (Go), `LIBGL_DEBUG=verbose`, `LD_DEBUG=libs`
(which libraries and where from).

Reading the trace: group by what matters, not by order. `openat(...) = -1 ENOENT` lines are the config paths it
*looks for* (user config, then system config: the search order is part of the spec). `rename(tmp, final)` after a
`write` is how it saves atomically. `execve` lines are the helpers it shells out to.

The GUI-is-a-front-for-a-CLI test: if the trace shows `execve("/usr/bin/flatpak", ["flatpak","override",...])` or a
write to a plain file, a bash wrapper is the whole rewrite (`bash-everything`). The user's `flatseal` came from exactly this:
Flatseal writes `flatpak override` files.

## 2. Static: its code without running it

```sh
file PROG; ldd PROG; readelf -d PROG | rg NEEDED          # kind, libraries (a Qt or GTK or SDL dependency says the toolkit)
readelf -S PROG | rg -n 'debug|symtab|\.rodata'           # are there symbols and debug info
nm -D --defined-only PROG | head; nm -D -u PROG | head    # exported and imported functions (imports show what it calls: curl_easy_*, sqlite3_*, SSL_*)
strings -n 8 PROG | rg -i 'http|error|usage|%s|\.conf|/etc/'      # messages, format strings, paths
objdump -d --no-show-raw-insn -M intel PROG | less        # only when a function is already chosen
```

Symbols and strings answer a lot: an error string names the check that failed, a format string shows the output
layout, a `%d.%d.%d` shows a version. Chase a string to the code that uses it: in Ghidra, "Search - For Strings", then
the references (`ghidra`). Stripped, optimised C is still readable at function level; read one function at a time with
`scripts/DecompFunc.java`, not the whole program.

Windows `.exe`/`.dll`: `file` and `objdump -x` (imports); `strings -el` for UTF-16 strings; Ghidra reads PE too.
Running it under Wine is allowed for the user's own software only; keep it in a throwaway prefix (`WINEPREFIX=$(mktemp -d)`).

## 3. Dynamic: the values at run time

```sh
ltrace -f -s 100 -o re/lt.txt PROG ARGS                 # library calls with arguments (strcmp, getenv, fopen): the config keys it asks for
gdb -q -batch -ex 'break FUNC' -ex run -ex 'bt' -ex 'info args' -ex 'x/s $rdi' --args PROG ARGS     # stop at a function; the first argument (x86-64) is $rdi
gdb -q -batch -ex 'catch syscall openat' -ex run -ex bt --args PROG                                  # who opens that file
```

A logging shim when you want every call of one function with no debugger:

```c
/* shim.c: log every open() the program makes, then call the real one */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>

int open(const char *path, int flags, ...)
{
	static int (*real)(const char *, int, ...);
	va_list ap;
	int mode;

	if (!real)
		real = dlsym(RTLD_NEXT, "open");
	va_start(ap, flags);
	mode = va_arg(ap, int);
	va_end(ap);
	fprintf(stderr, "open(%s, 0x%x)\n", path, flags);
	return real(path, flags, mode);
}
```

`cc -shared -fPIC -O2 -o shim.so shim.c -ldl && LD_PRELOAD=$PWD/shim.so PROG`. Modern programs also call `openat`;
hook that too, or use strace. Statically linked and setuid programs ignore `LD_PRELOAD`. When the source exists, a
debug build with `-g -O0` and a few `fprintf`s beats all of this.

## Desktop and D-Bus apps

```sh
busctl --user list                                   # who is on the session bus
busctl --user tree org.example.App                   # its objects
busctl --user introspect org.example.App /org/example/App     # methods, properties, signals with types
busctl --user monitor org.example.App                # live: what the GUI sends when you click
gdbus call --session -d org.example.App -o /org/example/App -m org.example.App.Method ARG     # call it yourself
dconf watch /                                        # GSettings changes live (many GNOME/GTK apps keep settings here)
gsettings list-recursively org.example.App
```

Flatpak: `flatpak info --show-permissions APP`, `flatpak info --show-metadata APP`, files in `~/.var/app/APP/`;
`flatpak run --command=sh APP` gives a shell inside its sandbox. Electron: the app is `resources/app.asar`
(`npx asar extract app.asar out/`), and the logic is JavaScript. Qt/QML apps often carry their UI as `.qml` in a
resource: `strings` it, or `rcc`-style extraction.

## Managed languages and bundles

- Python: usually installed as source (`python3 -c 'import m; print(m.__file__)'`); a frozen exe unpacks with
  its own extractor; `.pyc` needs a decompiler matched to the Python version (`pycdc`, not packaged here).
- Java/Android: `jadx` (repo): `jadx -d out app.apk` gives Java source; `unzip -l` shows an APK's layout; resources
  in `res/` and `assets/` are plain files.
- .NET: `ilspycmd` (`games`); Mono assemblies and PE with managed code decompile to near-original C#.
- Node: `package.json` and the source are right there; a single bundled file: `npx prettier` then search.
- WebAssembly: `wasm-objdump`/`wasm2wat` from `wabt` (not installed here); in a browser app the `.wasm` is a network
  download in the HAR (`web`).
- Then `rg -l 'setting_name' out/` across the extracted tree and open the one file it points at.

## Safety

Run unknown binaries only in a throwaway environment (a container, `bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs ~ PROG`, a VM): tracing
runs the program for real, and a program you do not trust can delete files. For the user's own software on the user's own
machine the trace is the same as using it. Never attach to or modify a program that guards a licence or an
anti-cheat (`rea` boundaries).

## Result

A written answer to the question you asked, with the evidence: "settings are stored at `~/.config/app/x.ini`, key
`volume=0..100`, read on start (strace line 214)". That line goes to `re/NOTES.md`, then into the spec (`spec`).
