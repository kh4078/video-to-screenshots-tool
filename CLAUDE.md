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

Before picking timestamps for them, get these five answers — inferring them wrong is the
main cause of rework:

1. Full scroll coverage of every page, or one representative frame per page?
2. Should states be captured (empty, loading, error, modals)?
3. Should variants of the same page be split out (delivery vs. pickup, different regions)?
4. Include OS-level UI (share sheets, control center)?
5. **Where do the final images end up — Figma, or just files they'll place themselves?**
   This is a binary choice, nothing more. If Figma, place them there yourself (see below).
   If files, save the final captures to the output folder and stop — don't guess at or build
   support for any other destination (Notion, a slide deck, a specific doc structure, etc.).
   That's the user's call to work out with whatever assistant they're using at that moment,
   not something this tool's workflow should hardcode.

And read contact sheets at **400px per tile or wider**. At 240px page titles are illegible,
and page titles are the most reliable way to tell screens apart.

### Show the contact sheet before running the full-resolution capture — always

After step 2 (sweep + contact sheet) and before step 3 (full-res capture), stop and actually
show the user the contact sheet image. This applies **even when the five answers above already
fully determine which timestamps to capture** (e.g. "full scroll coverage" was the answer, so
there's technically nothing left to pick) — showing the sheet is not about picking timestamps,
it's the user's only chance to catch a bad recording (missed a screen, cut a scroll short,
jumped around) before you spend time on the expensive lossless full-res pass.

**Listing the timestamps you intend to capture, in text, does not satisfy this.** A list of
numbers gives the user nothing to judge — they can't tell if a screen looks right, if a scroll
is complete, or if the recording glitched, from `[9, 12, 15, 18, ...]`. Only looking at the
actual image tells them that. Open/display the contact sheet itself and wait for the user to
confirm (or flag a problem) before running step 3.

**"Show it" means pop it open in its own window — e.g. `open sheet.jpg` — not just render it
inline in the chat.** An inline render is easy to miss or scroll past, and gives the user no way
to flip between sheets from multiple videos side by side. Opening the file is unambiguous: it
puts a window on screen the user has to actually look at (or dismiss). Default to this whenever
the environment can shell out; only fall back to inline rendering if it genuinely can't.

**Name each contact sheet after its source video, never a generic `sheet.jpg`.** When more than
one video is being processed in the same session, generic names collide — Preview (or any image
viewer) opens all of them in one window with tabs, and `sheet.jpg` tells you nothing about which
tab is which. Name it after the video, e.g. `總覽表_服務地點.jpg` / `contact-sheet_home.jpg`, so
each open window is self-identifying without the user having to check the file path.

### Naming captures — always rename the local folder, regardless of destination

Never leave final captures named by their `t<seconds>` timestamp. This step happens
**unconditionally, before you even look at where they're going** — whether the destination
turns out to be Figma or plain files, the local folder gets the same treatment:

1. **Look at what each frame actually shows and name it after that** — the page/section and its
   state, e.g. `選擇城市-捷運站列表`, `服務地點-成功送出`. Don't guess from the timestamp or the
   surrounding order; open the image and read it.

   **Read images one at a time, never in a parallel batch, when the content is what determines
   the name or the section boundary.** Firing off several image reads in one go and then writing
   analysis from the results is a real, repeatable failure mode — it's easy to mismatch which
   description belongs to which file, especially past ~5 images or when several frames look
   similar (an overview screen re-appearing, a form section revisited). The failure is silent:
   the output still looks like a plausible story, it's just wrong, and it surfaces later as
   frames grouped under the wrong section heading. One read, note what it actually shows, then
   the next — slower, but the only way the attribution is guaranteed correct. Batch reads are
   still fine for things where mismatching one result doesn't matter (e.g. a final visual
   spot-check across images you've already named).
2. **If several frames are the same page/section captured at different scroll positions, name
   them as an explicit sequence** in scroll order — `..._1of3`, `..._2of3`, `..._3of3` — so the
   relationship is visible at a glance instead of looking like unrelated screens.

   **`_NofM` means "you need all of these together to see the full picture" — it is not a
   catch-all for "these frames look similar."** Before applying it, ask: does the next frame
   show anything the previous one didn't (new content scrolled into view, a new selection made,
   a new element on screen)? If yes, it's a genuine sequence — number it. If no — the frames are
   pixel-for-pixel (or near enough) the same — **keep only one of them and drop the suffix
   entirely.** This case is common at the *end* of a section: the fixed 3-second sampling grid
   doesn't know when the last real action happened, so if the recording lingers a few seconds
   after the user stopped interacting (a pause before hitting stop), two or more consecutive
   samples land on the same frozen screen. That's not a two-part reveal, it's dead recording time
   landing on the grid — labeling it `_1of2`/`_2of2` overstates what's there and misleads anyone
   reading the names later. Delete the redundant capture (local file and, if already placed,
   the Figma layer + caption) and keep the single representative one, named without a suffix.
3. **Rename in place inside the same folder the final-capture step already wrote to** (step 3's
   output, e.g. `02_picked`) — don't create a second folder for renamed copies. That folder only
   ever holds the hand-picked final captures, so there's nothing to protect by keeping the
   originals, and a second copy just doubles disk usage for no benefit. `01_sweep` (the low-res
   sweep) is a separate, disposable working folder — fine to leave its `t<seconds>` names as-is,
   or delete it once step 3 is done.

Do this before considering the job done, regardless of destination. The two destinations only
diverge on what happens *next*:

- **Files**: nothing further — the renamed folder from step 3 is the deliverable.
- **Figma**: place the images there using **the same names** you just gave the local files —
  same layer name, same caption text (below). Don't let the two drift into different naming —
  the semantic name was already worked out once (that's the part that costs real time, since it
  requires reading each image); reusing it for the local files afterward is a cheap rename, not
  a redo, so there's no excuse for the two to disagree.

### Extra step when the destination is Figma

Beyond naming the layer correctly, add a small text node directly below each image showing
that same layer name as a caption. The point is identifying a screen at a glance while scanning
the canvas, without having to open the layers panel for every tile.

### Uploading to Figma via curl — never put a literal comma in the filename

If the upload step POSTs files with `curl -F "file=@<filename>"` (multipart form), a `,` inside
`<filename>` breaks it: curl's `-F` syntax treats a comma in the `@`-path as a separator for
uploading *multiple* files under one field, so `..._已加入(週末,含報價提醒)_1of2.png` gets split
into two bogus paths that don't exist on disk, and the upload fails with
`curl: (26) Failed to open/read local data from file/application` — while filenames without a
comma upload fine, making the failure look intermittent/random rather than what it is
(deterministic, keyed on one character). This is a `curl` behavior, not a Figma or network issue.

**Avoid the semantic names you're already generating (see above) ever containing a literal `,`.**
Use the ideographic comma `、` instead when a name needs to list multiple things — it reads
naturally in Chinese anyway, so this isn't a workaround-looking substitution, e.g.
`_已加入(週末、含報價提醒)_1of2`. If a comma already slipped into a filename before uploading,
rename it (swap `,` → `、`) before the upload step, not after — retrying the same broken name
just fails again.

### Layout spacing when placing into Figma

Get this right the first time — it's easy to build a board that's technically correct but
uncomfortable to scan, and to only notice once it's full of images.

1. **Group each image with its own caption** in a small vertical auto-layout, tight spacing
   between the two (6–8px). That tightness is what visually says "this caption belongs to the
   image right above it."
2. **Arrange those groups in a wrapping grid** (`layoutMode: 'HORIZONTAL'`, `layoutWrap: 'WRAP'`)
   so the set reads as a scannable board, not one long vertical scroll.
3. **Row gap must be clearly bigger than the image-caption gap — at least 3–4x it** (e.g. 60–80px
   of row gap against a 6–8px image-caption gap). If the row gap is close to the image-caption
   gap, a caption sits about as near the row below as its own image above, and it stops being
   obvious which image it labels. This was a real bug in an earlier pass, not a hypothetical one.
4. Column gap (`itemSpacing`) around 20px is enough — left/right neighbors are already visually
   separated by the image edges themselves.
5. **Give the outermost per-video-segment container real padding on all sides** (e.g. 40px).
   Content flush against the frame edge reads as cramped.
6. **When multiple segments land on the same page** (e.g. one container per source video),
   stack them with a clear gap (100px+), and re-check for overlap after touching any spacing
   value above — increasing row gap or padding grows a hugging container's height, which can
   push it into whatever sits below it on the page.
