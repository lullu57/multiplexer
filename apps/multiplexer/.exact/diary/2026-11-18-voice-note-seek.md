surfaces: ios
agent: claude fable 5.2
task: let a reader tap or drag along a chat app's voice message waveform to move through it

### Rough
- a drive's `tap <target> drag 0 -160` on a node with `pan` and `touch-action="pan-y"` answered
  `delivery recognized` and ran the node's `pan` and `panrelease` with a vertical move. a real
  touch does not: the list scrolls and the pan hears nothing. so the drive showed a defect (a
  scroll that began on the node ran the release action) that a finger cannot produce, and the
  same drive on a plain node beside it was refused with "a gesture only a real touch makes ...
  drive with --touch platform". about fifteen minutes and four drives before `--touch platform`
  gave the real answer. what would help: without `--touch platform`, a drag on a `pan` node
  follows the node's `touch-action` (a vertical drag on `pan-y` goes to the scroller or is
  refused), or the reply names that the pan was called directly, past the gesture rules.
- a `panrelease` bound through a component's `action` prop to an action with no free parameter
  was refused with "`X.drop` requires 2 action parameter(s), but this binding to `land` supplies
  2 of its 2". the numbers read as a match. the cause: `panrelease` hands two velocities, and the
  bound action had no parameters left to take them. one build. what would help: "`panrelease`
  hands 2 values (x and y velocity); `land` has 0 parameters left to take them".
- `scale="1 1.15"` (taller, not wider) was refused: `scale` takes one number. no doc line names
  a one-axis scale. dropped the effect. what would help: a two-value `scale`, as CSS has, or the
  error naming the alternative.
- under `--touch platform`, `during "screenshot ..."` on a drag needs `hold <ms>`; the error said
  so and cost one drive.
- a drive could not record sound: a press on the record control left the app waiting on the
  microphone, with the simulator's microphone permission granted. so a recorded draft's player
  could not be driven. no error; the state stayed at its first step. what would help: a doc line
  on whether a drive can open the microphone, and how.

### Lean in
- `fastSeek(id, seconds)` plus a bound `currentTime` covered both cases with no native code: a
  seek in the sound that plays, and a start from the tapped place for one not loaded yet.
- `pointerdown` (where the finger landed) with `pan` (how far it moved) and `press` (a tap) made a
  scrubber on a plain node. with `touch-action="pan-y"` the list still scrolls from it, and the
  inner `pan` won over an ancestor's `swiperight`, as the docs say.
- `clock +N real` and `state media` showed the player's true time after each seek.

### Needed
- nothing new from the framework for this task.

### Checkpoints
- a tap at the waveform's middle starts a 24 s voice message at 12 s; it plays on from there.
- a drag shows a playhead, the bars and the time left at once; on the lift the sound moves there
  and keeps its state (playing stays playing, paused stays paused).
- a drag past the start lands at 0. a vertical drag from the waveform scrolls and seeks nothing.
- a swipe right from the rest of the bubble still starts a reply; a long press does not seek.
