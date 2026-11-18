surfaces: ios
agent: claude fable 5.2
task: make a chat app's hand-drawn long-press message menu open and close with motion

### Rough
- the lifted copy of a held bubble (`contextTarget` + `contextMagnify`) is placed by the host in
  one frame: the host sets the vertical place of the nearest absolute ancestor (over the source,
  or moved so the menu fits) and scales the copy. the app's own `top` and a `translate` with a
  spring `transition` on that ancestor had no visible effect: the first filmed frame already
  showed the resting place, 66 points from the held bubble. so the reactions and actions can
  animate in (keyframes work on them), but the bubble itself jumps when the menu does not fit
  around it, which is the one move a native context menu animates. finding it took three builds,
  three filmed drives and reading the iOS presenter (`positionContexts`), about forty minutes.
  what would help: the host animates the panel from the source's box to its resting box (and the
  magnify scale with it), or exposes the resting offset so the app can; and `contextTarget` and
  `contextMagnify` have a docs entry that says the host owns the panel's vertical place.
- `contextTarget` and `contextMagnify` are in the schema and both hosts but in no doc. the sample
  chat app is the only place that shows them.
- the sample chat app defines an exit keyframe for its menu but never uses it, and its menu's
  dim layer and action list appear in one frame. a reader who copies the sample gets an abrupt
  menu. what would help: the sample uses `-exact-exit-animation` and an entrance on each part.
- a keyframe takes literals only, so a "grow out of the held bubble's corner" entrance needs the
  corner as `transform-origin` on the node, chosen by state. this worked; the motion recipe does
  not say that `transform-origin` may be dynamic while the keyframe is literal.

### Lean in
- `-exact-exit-animation` on the overlay's root gave a fade out with one line, and the app's
  state could clear at once.
- `animation` with a `cubic-bezier` whose second value is above 1 gives a small overshoot, which
  stands in for a spring that `animation` refuses.
- `screenshot <png> over 450 every 50 window` after `tap <target> contextmenu` shows each part's
  progress frame by frame.

### Needed
- an animated lift for a context panel (above).

### Checkpoints
- opening: the blur fades in, the reactions grow from the bubble's upper corner, the actions grow
  from its lower corner, about 250 ms, incoming and own messages.
- closing: the whole menu fades in about 180 ms.
- reduced motion: fades only.
