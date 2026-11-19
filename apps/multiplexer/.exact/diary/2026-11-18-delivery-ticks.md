surfaces: ios
agent: claude fable 5.2
task: show an own message's receipt as ticks (one sent, two delivered, two tinted read) in a chat app's status line and chat list

### Rough
- an `svg` cannot sit inside a `text` paragraph. the first try put a small svg component before the
  status word and before the chat list's preview, as an inline `image "symbol:…"` already sits
  there. the compiler said "a text paragraph holds `text` or `time` runs and `image`s"
  (`lower-leaf-children`). the message is clear, but it leaves two ways to draw one glyph: a `row`
  with an `svg` where the text is one line (the status line), and an icon token where the glyph
  must flow inside a clamped two-line paragraph (the list's preview). about ten minutes. what would
  help: an inline `svg` in a paragraph, or a line in the svg vocab card that says a paragraph takes
  only `image`s and names the icon token as the inline way.
- the next try drew the list's marks as icon tokens (`icon(svg "…")`), which a paragraph takes.
  an icon's svg must be filled paths with no stroke; the compiler's message (`tamber-icon-svg`)
  is exact and names the fix, but the framework has no tool for it, so a script outlined each
  round-capped stroke. then the drive showed that an icon is always drawn in a square about 0.7
  of its text's size, whatever `width` says: the pair of checks (wider than tall) came out with
  checks two thirds as tall as the single check's. `font-size="1.4em"` on the icon fixed its size
  and made its line taller (the preview moved down 3 points); `line-height` on the icon or on the
  paragraph did not undo that. four drives, about thirty minutes, and the icons were dropped for
  a `row` of an `svg` and the paragraph, so a second line starts under the first, not under the
  marks. what would help: the symbols recipe says an icon's box is a square of the text size and
  that a wide glyph is fitted into it; or an icon keeps its viewBox's ratio at the text's height.
- a computed `vertical-align` on an inline image failed only in the web target's check ("a dynamic
  `vertical_align` (Enum) is not one declaration; not in the JS target"), reported as a
  `typescript-check` error in `app.ts` line 0. the fix was two `if` branches. the message does not
  say which values are allowed to be computed.
- `contract vocab svg` does not say what `em` means on an `svg`'s width. in a `row` with
  `font="-exact-caption1"` the svg's em followed that font (0.8em drew about 9.6 points at 12). in
  a `row` with `font="-exact-subheadline"` 0.68em drew about 7 points, not 10: the size was set by
  eye from screenshots. both scale with the reader's text size.

### Lean in
- an `svg` with `em` sizes in a row follows the reader's text size, so a hand-drawn glyph needs no icon file.
- the compiler's error for the stroked icon said what each host can draw and how to fix the file.
- `prefer prefers-color-scheme dark` and `prefer root-font-size 53` inside one drive gave the dark
  and largest-text screenshots without a second launch.

### Needed
- nothing blocked the task.

### Checkpoints
- a sent message: one grey check and "Sent"; the send still flies and lands, and the status line opens under it.
- after a delivery report: two grey checks and "Delivered", in the chat and in the chat list; kept after a relaunch.
- after a read receipt: two checks in the accent and "Seen", in the chat and in the chat list.
- dark appearance and the largest text: the checks keep the text's colour role and size; a status of two lines starts each line after the checks.
