# workflow (vibemix)

A technique for making new software: the user names programs as examples and the features or concepts liked most in
each; the job is to build that mix in the user's own way - the user's languages, conventions, UI and names. Typical
results: a git client that combines magit and lazygit, an editor with micro keys and multicursor, a note tool that
mixes ideas from two others.

A mix is not a clone: the aim is the experience of the liked features working together, not feature parity with any
single program.

## 1. Take the list down

- Capture the user's wording per program, one line each, in the project's `braindump.md` (`workflow (braindump)`): "X: how it handles
  Y", "Y: the way Z works". Several wishes in one message are split. Nothing is built while the user is still listing.
- Name what is liked, not the program: "jump to anything with two keys" is the feature; the program only says where to
  look at it.
- A feature the user named that you cannot place in the program: ask once with the guess and the default marked (`rules (clarify)`),
  then go.

## 1b. Ask the design questions (detailed, before the design is fixed)

The list says what the user likes; it does not say how it should *look and behave*. Ask for that, concretely, once per mix, before step 3.
Answers shape the design; guessing here costs a rebuild.

1. Make the questions specific to the liked features, never generic ("what theme?"). Each one names the feature, gives the guess,
   marks the default, and offers 2-3 concrete options: "jump to anything: labels over the text like easymotion, or a prompt like fzf? default: labels".
2. Cover what changes the design, in this order: **the main screen** (layout, what is always visible, what hides), **the keys** (modal or
   chords, the first ten keys, what the key bar shows), **the look** (colours, borders, density, fonts: the user's usual look unless said otherwise,
   `ui`), **motion and feedback** (animation, sounds, how errors show), **the data** (where state lives, what a "session" or "project" is, what survives a restart),
   **the edges** (empty state, huge input, first run), **scope** (the one thing to cut if it grows), **name and where it lives** (repo, binary, one file or many).
3. Batch them: 4-8 questions in one message (or `AskUserQuestion`, 4 at most per call, with the default first), grouped by the list above, short. Not one question per turn.
4. Not blocking: while the user answers, build what the answers cannot change (the core data structure, the test harness, the check script). In AFK mode the
   questions go as lines into the one central `questions.md` with the default taken, and the work goes on; the user's answer later is a diff, not a restart.
5. Write the answers into `braindump.md` next to the features they belong to, and into `re/vibemix.md`'s table (feature, source, spec line, **decision**), so step 5 can say why it looks the way it does.
6. A second round is fine after the first slice is on screen: the user reacts better to something the user can see ("the key bar is too busy") than to an option list. Ask what is still open after the slice, not what the user already answered.

## 2. Find out what each feature really is

- Use the program if it is installed, or read its docs and manual (`rules (rtfm)`); watch how it behaves, not how it is
  written. The `rea` method applies: black box first, a short spec line per feature ("press g then two letters: the
  cursor moves to the matching label; labels are assigned left to right, nearest first") with how it was checked.
- Behaviour and ideas are free to rebuild; source code is not copied. Look at licenses before reading source at all;
  a clean reimplementation comes from the spec (`rea (spec)`).
- Notes live in `re/vibemix.md`: feature, source program, spec line, status. They stay out of the shipped repo: the user's
  rule is no influence namedropping in committed text (`conventions (docs)`); legal attribution applies only to code
  that was actually copied, which here is none.

## 3. Mix into one design

- One model underneath. Two programs often disagree (modal keys vs. chords, buffers vs. tabs, tree vs. graph): pick
  the model that fits the most liked features, and say what the other features become inside it. A table helps:
  feature -> source -> how it looks in our model -> cost (`workflow (brainstorm)` when two models are really possible).
- Cut anything not on the user's list, however standard in the source programs (`code (ponytail)`). Missing standard features are
  the user's call; offer them as a single line at the end, do not build them.
- Name it the user's way: own short name, no "-clone", no "X-like" in the README.

## 4. Build it the user's way

- Language by the job (`code (languages)`); C in the usual style - arenas and pools, flat data, no hidden allocation, C89
  (`code (languages)`). TUIs with a key bar and a numbered fallback (`ui (ui-designer)`); one `run` file,
  `--help` from the header, a README per standalone folder, Conventional Commits (`conventions`).
- The smallest slice that shows the mix first: two or three of the liked features working together end to end, not
  all features half-done. Then show it and let the user review; the user's corrections feed the next round
  (`afk-loop (working loop)`: code, tests, lean4, allocator check, bench, commit).
- Reuse what the user already built before writing new parts (the user's own libraries and allocators):
  the mix is mostly assembly of existing blocks around the new idea.

## 5. Keep the trail

`re/vibemix.md` is the map back: which liked feature became which module. Features dropped on the way stay in it with
the reason. A new example from the user later is appended to the list and goes through steps 2-4 again.
