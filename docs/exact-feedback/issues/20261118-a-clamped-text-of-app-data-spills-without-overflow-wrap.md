# A clamped text of app data spills without `overflow-wrap`, and nothing flags it before a drive

**Status:** Open
**Systems:** check, contract compiler, sample chat app
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A chat app's reply bar shows the quoted message in one line. With a long link, the quoted text
ran past its column and under the bar's close button, although the column had `min-width=0` and
the text had `line-clamp`. The pitfalls page names the fix (`overflow-wrap="anywhere"`), and it
worked the first time. The quote card above a reply's bubble needed the same fix.

The sample chat app's reply bar and quote have the same two texts without `overflow-wrap`, so an
app that copies them gets the same spill with a long link.

Cost: one drive and a screenshot to find; the fix itself was quick.

## What would help

- `check`, or the compiler, names a `line-clamp` text of app data that has no `overflow-wrap`.
- The sample chat app's reply bar and quote use `overflow-wrap`.

Related: [a text that spills its box shows only in check](20261106-a-text-that-spills-its-box.md),
which asks for a whole-list `check`; this one asks for a static warning before any drive.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, light and dark, keyboard up.
