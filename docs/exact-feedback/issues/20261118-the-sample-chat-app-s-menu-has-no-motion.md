# The sample chat app's menu has no motion, and the motion recipe omits a dynamic `transform-origin`

**Status:** Open
**Systems:** sample chat app, docs (motion recipe)
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

The sample chat app defines an exit keyframe for its long-press menu but never uses it. Its
menu's dim layer and action list appear in one frame. A reader who copies the sample gets an
abrupt menu.

A keyframe takes literals only. So a "grow out of the held bubble's corner" entrance needs the
corner as `transform-origin` on the node, chosen by state, with a literal keyframe. This worked,
but the motion recipe does not say that `transform-origin` may be dynamic while the keyframe is
literal.

Cost: part of a forty-minute task; no single build was lost to it.

## What would help

- The sample uses `-exact-exit-animation` on the menu's root and an entrance on each part.
- One line in the motion recipe: a keyframe is literal, and a state-chosen `transform-origin` on
  the node picks where it grows from.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator. `-exact-exit-animation` on the
overlay's root gave a fade out with one line, and a `cubic-bezier` with a second value above 1
gave a small overshoot in place of a spring.
