# `scrollIntoView` to a row not yet in a virtualized list does nothing, and says nothing

**Status:** Open
**Systems:** runtime (virtualized list), docs (chat-thread recipe)
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A chat app sends a message from three screens up in a virtualized list. The sending action calls
`scrollIntoView("<list>", key, offset=..., behavior="smooth")` for the row that the same action's
optimistic `send` adds. The call did nothing and reported nothing: the list stayed where it was
for four seconds, and the flying bubble faded at the field. Near the end of the list the same call
works, so earlier drives and a recorded check ("a send from higher up reaches the end") had
passed.

The fix was to call the scroll from a task gated on the row being in the list
(`when ... and lastKey == sentKey`, `after(1, ...)`).

The chat recipe shows `scrollIntoView(..., lastId, block="end")` in the mutation's `then`. It
does not say that a call in the sending action itself cannot see the optimistic row, which is
where an app that animates the send has to call it.

The app then needed to start the flight when the smooth scroll ended. It polled a state kept by
the list's `scroll` event from an every-frame task. The grammar does document `scrollend` on a
`list` and `wait=scrollend` on timers, but neither `scrollIntoView`'s entry nor the chat recipe
points to them, and they were not found during the task.

Cost: one filmed drive, about twenty minutes.

## What would help

- A scroll to a key that is not in the list yet waits one commit for it, or the runtime and the
  drive log name the missing key ("scrollIntoView: no row with key ... in list ...").
- The chat recipe says where a send's scroll may be called, relative to the optimistic row.
- `scrollIntoView`'s entry links to `scrollend`, or takes a `then=<action>` for when the scroll
  ends.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, filmed with
`screenshot <png> over 1800 every 150 window`.
