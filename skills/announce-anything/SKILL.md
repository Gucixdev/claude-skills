---
name: announce-anything
description: Posts about his GitHub projects on Reddit, Hacker News, Lobsters, dev.to, Mastodon. Checks each public repo for blunders first (secrets, identity, machine paths, no README or licence, generated-sounding text), drafts the post per place, never posts by itself. Use for announce, promote, Show HN, reddit, hackernews, ogloszenie, promocja repo.
metadata:
  priority: "2"
  tags: "#publish #social #reddit #hackernews #github #release #security #privacy #marketing"
  requires: "skill:publish-anything skill:ship-anything skill:rules cmd:gh cmd:git cmd:curl"
---

# announce-anything

A post is a link to his GitHub with a few lines in front of it. Whatever is wrong anywhere on the profile gets found
within the hour, in public, with his name on it. So the order is: **gate, draft, he posts.**

<!-- digest -->

## 1. Gate (blocking)

```sh
scripts/announce-check                 # every public, non-fork repo of the logged-in account, as GitHub shows it
scripts/announce-check -p post.md REPO # one repo, plus the text of the post
```

It clones from GitHub (what the public sees, not the working copy) and checks per repo: `publish-check` on the tree
(secrets, login and home path, `/data/dev` paths, comments that read as generated), the identity on the last 200
commits (only `Gucixdev` and the noreply address may show), token shapes in their diffs (gitleaks over the history
when installed), a README, a LICENSE, a description. For the post: his identity, marketing words, emoji, the 80
character Hacker News title limit, every link answers 2xx.

Everything it prints is fixed or consciously accepted before a word is posted. A secret found in a public repo is
revoked at the provider first, then removed from history (`publish-anything`); do not rewrite history without his
go-ahead. Also before the post, for the repo being announced (`ship-anything`): tests pass on a clean clone, the
install command in the README works on a clean machine, the README opens with one real command and its real output,
claims have numbers. Screenshots, GIFs and `autodemo` recordings: look at them - prompt, hostname, window title,
paths, tabs, notifications, a username in a file picker.

Do not announce a repo that is empty, a stub, or documented only by its name. A repo the post links to that has no
README is a worse post than no post.

## 2. Draft

Drafts go to `announce/REPO/PLATFORM.md` in claude-config (private), first line = title. English for the English
places. Same shape everywhere:

1. **What it is**, one sentence, no adjectives.
2. **Why it exists / what is different**, one sentence with a number or a concrete fact (lines of code, ms, bytes,
   tests).
3. **How to try it**, one command.
4. **Limits**, plainly: what it does not do, what is untested. Readers respect this and attack the hidden version.
5. The link. Say that he wrote it.

No "excited to announce", no emoji, no "revolutionary / blazing / seamless / robust", no begging for stars or upvotes,
no hashtags except where the place uses them. Write like a man describing his tool to another, not a launch page.

| Place | Shape |
|---|---|
| Hacker News | `Show HN: Name - what it does` (80 characters max, no caps lock, no marketing words), URL = the repo, text empty or short; then a first comment from him with the background and the limits. Weekday, US morning. He stays 2-3 hours to answer. Once per project; a flop is not reposted. Never ask for upvotes, never share the link for voting. |
| Reddit | One subreddit per post, matching the project (C: r/C_Programming; Rust: r/rust; init and CLI: r/linux, r/commandline; self-hosted: r/selfhosted; open source: r/opensource, r/coolgithubprojects). The subreddit's rules and flair are read the day of posting - they change, and self-promotion limits differ - and followed. Say it is his. Not the same post in ten subs on one day. Answer comments. |
| Lobsters | Invite-only: he posts, tags `show` plus the language, author box ticked. |
| dev.to / blog | A story: the problem, the one design decision, a measured result. Longer than the others, same limits section. |
| Mastodon | Short, link, plain hashtags (`#opensource #clang`), no thread of ten. |

Rules differ and drift. Anything about a place's current rules is UNSURE until the rules page was read that day
(`rules`: say how sure you are).

## 3. He posts

Posting is outward and cannot be taken back (`rules`). Claude writes the draft and the gate result and stops. It does
not log in, use an API token, or post on any account unless he says "post it" for that exact draft on that exact
place. No second accounts, no asking friends to upvote, no scheduling bursts - that gets the project banned from the
place and him marked as a spammer.

After posting: one line per post in `announce/LOG.md` (date, place, URL, repo). Comments, issues and PRs that arrive
are answered by him; Claude can draft replies, fix reported bugs in a branch and re-run the gate.
