# An inline glyph in a paragraph must be an icon token, and an icon is fitted into a square

**Status:** Open
**Systems:** contract lowering, tamber icons, docs (symbols recipe, svg vocab)
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A chat app shows a message's receipt as small checks before the status word and before the chat
list's two-line preview.

1. An `svg` cannot sit inside a `text` paragraph. The compiler said "a text paragraph holds
   `text` or `time` runs and `image`s" (`lower-leaf-children`). The message is clear, but it
   leaves two ways to draw one glyph: a `row` with an `svg` where the text is one line, and an
   icon token where the glyph must flow inside a clamped paragraph. About ten minutes.
2. An icon token's svg must be filled paths with no stroke. The compiler's message
   (`tamber-icon-svg`) is exact and names the fix, but the framework has no tool to outline a
   stroke, so a script outlined each round-capped stroke.
3. An icon is always drawn in a square about 0.7 of its text's size, whatever `width` says. A
   pair of checks (wider than tall) came out with checks two thirds as tall as the single check.
   `font-size="1.4em"` on the icon fixed its size but made its line taller (the preview moved down
   3 points); `line-height` on the icon or on the paragraph did not undo that.

After four drives (about thirty minutes) the icons were dropped for a `row` of an `svg` and the
paragraph, so a second line starts under the first, not under the marks.

## What would help

- An inline `svg` in a paragraph, or a line in the svg vocab card that says a paragraph takes
  only `image`s and names the icon token as the inline way.
- An icon keeps its viewBox's ratio at the text's height, or the symbols recipe says an icon's
  box is a square of the text size and that a wide glyph is fitted into it.
- A tool, or a documented step, that turns a stroked svg into the filled paths an icon needs.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, light and dark, default and largest text.
