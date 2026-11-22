---
name: audit-everything
description: Audit anything - run what can be run (two compilers and sanitizers, shellcheck, tests as shipped), scan secrets, dependencies and licenses, audit a system against Cyber Essentials, check public claims as a recruiter reads them; reports in the ponytail format. Use for an audit, a review, a check of a repo or system, or is this ready.
metadata:
  priority: "2"
  tags: "#thirdparties #audit #review #security #quality #dev"
  requires: "skill:code skill:code skill:code ?cmd:shellcheck ?cmd:gcc|clang ?cmd:lynis"
  upstream: "DietrichGebert/ponytail@16352ac JuliusBrussee/caveman@81958ad"
---

# audit-everything

A review or audit is a report: findings only, no code changed, unless he asks for the fixes too.

## Run it, don't only read it

- Build and run the tests as shipped. C: gcc and clang, `-Wall -Wextra -pedantic`, ASan + UBSan, a TSan build when
  there are threads (2026-10-18: signed-overflow UB in `abs_i32`, an ignored `truncate()` return, a cold-store record
  desync - none visible by reading). Bash: `shellcheck -S warning`, the bats suite, `mawk` or busybox awk for
  portability (a gawk-only regex hid in `logcollector`). Python: the tests with warnings as errors.
- Secrets: `git log -p | grep -nE '(token|secret|passw(or)?d|api[_-]?key)[[:space:]]*[:=]'`, `.env` files, keys in
  history - and his identity rules (`rules (identity)`).
- Dependencies: what is pulled in and why, versions pinned or not, known advisories (`npm audit`, `cargo audit`,
  `pip-audit` when present), licenses compatible with his MIT/GPL code.
- A system: failed units (`systemctl --failed`), the journal's repeated errors (his `logcollector`), open ports (`ss
  -tlnp`), users and sudoers, SSH config, updates pending, firewall, disk encryption, backups that restore; `lynis
  audit system` when installed. For client machines his Cyber Essentials checklist is the frame: firewalls, secure
  configuration, user access control, malware protection, security update management.

## Claims

README or comments that promise more than the code does ("production-ready" with a TSan failure, inflated memory
claims), AI-flavoured phrasing, a single-day 79k-line commit dump - what a recruiter or client would notice.

## Method and report

The review method, the findings order and the report: `code (review)`; a whole repo: `code (ponytail)`; comments to
paste into a PR: `code (review)`; the shortcut ledger: `code (ponytail)`.
