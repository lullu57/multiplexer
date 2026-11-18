# The host places a long-press context panel in one frame, and `contextTarget` is undocumented

**Status:** Open
**Systems:** iOS host (context presenter), docs
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A chat app draws its long-press message menu by hand: a lifted copy of the held bubble under
`contextTarget` and `contextMagnify`, with reactions above and actions below. The task was to
make it open and close with motion.

The host places the lifted copy in one frame. It sets the vertical place of the nearest absolute
ancestor (over the source, or moved so the menu fits) and scales the copy. The app's own `top`,
and a `translate` with a spring `transition` on that ancestor, had no visible effect: the first
filmed frame already showed the resting place, 66 points from the held bubble. The reactions and
actions can animate in (keyframes work on them), but the bubble itself jumps when the menu does
not fit around it. That is the one move a native context menu animates.

`contextTarget` and `contextMagnify` are in the schema and on both hosts, but in no doc. The
sample chat app is the only place that shows them. Nothing says that the host owns the panel's
vertical place.

Cost: three builds, three filmed drives and reading the iOS presenter (`positionContexts`),
about forty minutes.

## What would help

- The host animates the panel from the source's box to its resting box (and the magnify scale
  with it), or exposes the resting offset so the app can animate it.
- A docs entry for `contextTarget` and `contextMagnify` that says the host owns the panel's
  vertical place and scale.

Related: [a long-press menu has no row of reactions](20261031-a-long-press-menu-has-no.md), the
reason the menu is drawn by hand.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, filmed with
`tap <target> contextmenu` and `screenshot <png> over 450 every 50 window`.
