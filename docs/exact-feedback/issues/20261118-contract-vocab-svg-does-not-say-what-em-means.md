# `contract vocab svg` does not say what `em` means on an svg's width

**Status:** Open
**Systems:** docs (svg vocab), layout
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A chat app draws small checks as an `svg` with `em` sizes in a `row`, so they follow the reader's
text size. `contract vocab svg` does not say which font an svg's `em` follows.

In a `row` with `font="-exact-caption1"` the svg's em followed that font (0.8em drew about 9.6
points at 12). In a `row` with `font="-exact-subheadline"`, 0.68em drew about 7 points, not 10.
The sizes were set by eye from screenshots. Both scale with the reader's text size.

Cost: several screenshot drives, part of a thirty-minute icon task.

## What would help

A line in the svg vocab card: which font an svg's `em` refers to, and how it relates to the
`row`'s `font`.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, default and largest text.
