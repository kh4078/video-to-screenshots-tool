# Project rules for AI coding agents

This file is read automatically by Claude Code and similar tools. It also works as `AGENTS.md`.
Read [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before proposing any change.

## What this project is

Two small Swift command-line programs that extract stills from a screen recording (`frames`)
and tile them into a labelled contact sheet (`montage`), so a human can pick which moments
matter. Built for designers doing product walkthroughs, IA audits, UI archiving, and
competitor research.

## Hard constraints — do not violate these

1. **Zero dependencies.** No packages, no ffmpeg, no package managers. Only frameworks that
   ship with macOS (AVFoundation, AppKit, Foundation). This is the project's entire value
   proposition. If a task seems to need a dependency, say so and stop — do not add one.
2. **macOS only.** Do not add cross-platform shims or suggest porting.
3. **No automatic frame selection.** Never add scene detection, "smart" keyframe picking, or
   any heuristic that decides which frames matter. Selection requires knowing the user's goal;
   the tool's job is to make human selection fast. Automated selection hides what it skipped
   and cannot be corrected.
4. **No GUI.** Command-line only.
5. **`frames` and `montage` are a matched pair.** `montage` reads `.jpg` and parses timestamps
   from `frames`' filename format (`t%06.1f`). Changing one side's output format requires
   changing the other in the same change.
6. **Don't break existing command syntax.** Users have scripts built on the current argument
   order. If a change must alter it, flag it prominently.

## Code conventions

- Plain Swift, no external modules. Each tool is a single self-contained `.swift` file.
- Both compile with `swiftc <file>.swift -o <name>` — keep them single-file.
- Comments are in Traditional Chinese (the maintainer's language). Match that when editing
  existing files; new user-facing docs are bilingual (English first, then 繁體中文).
- After changing a `.swift` file, recompile — the binary is what actually runs:
  ```bash
  swiftc frames.swift -o frames && swiftc montage.swift -o montage
  ```

## Testing a change

There is no automated test suite. Verify manually:

```bash
FRAMES_FORMAT=png ./frames <a real screen recording> /tmp/t 0 1206 5 10
./montage /tmp/t /tmp/sheet.jpg 4 300
```

Then **actually open the output images and look at them.** Check that frames aren't cropped,
that the contact sheet labels match the timestamps, and that nothing is upside down or
letterboxed. A script that exits 0 is not evidence that the output is correct.

## Known rough edges (already documented, don't "fix" as a surprise)

- Two deprecation warnings on build (`asset.duration`, `copyCGImage`) — harmless
- Frame tolerance is 0.3s for speed, not `.zero`
- `montage` assumes all images share the first image's aspect ratio
- Only tested against iPhone screen recordings

## If you're helping someone use this tool (not modify it)

Before picking timestamps for them, get these four answers — inferring them wrong is the
main cause of rework:

1. Full scroll coverage of every page, or one representative frame per page?
2. Should states be captured (empty, loading, error, modals)?
3. Should variants of the same page be split out (delivery vs. pickup, different regions)?
4. Include OS-level UI (share sheets, control center)?

And read contact sheets at **400px per tile or wider**. At 240px page titles are illegible,
and page titles are the most reliable way to tell screens apart.
