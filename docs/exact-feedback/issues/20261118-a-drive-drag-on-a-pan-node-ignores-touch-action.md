# A drive's drag on a `pan` node ignores `touch-action` unless `--touch platform` is set

**Status:** Open
**Systems:** agent drive (iOS)
**Severity:** P2
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A node has `pan`, `panrelease` and `touch-action="pan-y"`, inside a vertical list. A drive's
`tap <node> drag 0 -160` answers `delivery recognized` and runs the node's `pan` and
`panrelease` with the vertical move. A real touch does not: the list scrolls and the pan hears
nothing. The drive therefore showed a defect (a scroll that began on the node ran the release
action) that a finger cannot produce. The same drag on a plain node beside it was refused with
"a gesture only a real touch makes ... drive with --touch platform", so the two answers disagree.

Cost: about fifteen minutes and four drives.

## What would help

- Without `--touch platform`, a drag on a `pan` node follows the node's `touch-action`: a
  vertical drag on `pan-y` goes to the scroller, or is refused as the plain node's is.
- Or the reply says that the pan was called directly, past the gesture rules.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator. With `--touch platform` the same vertical
drag scrolled the list and ran no pan action, and a horizontal drag ran the pan.
