surfaces: ios
agent: claude fable 5.2
task: when a message is sent while a chat is scrolled up, go to the chat's end first, then fly the bubble

### Rough
- `scrollIntoView("<list>", key, offset=..., behavior="smooth")` did nothing, and said nothing, when
  the key was a row that the same action's optimistic `send` adds and the reader was far from the
  end of a virtualized list (three screens up). the list stayed where it was for four seconds and
  the flying bubble faded at the field. near the end the same call works, so earlier drives and a
  recorded check ("a send from higher up reaches the end") had passed. finding it took one filmed
  drive; the fix was to call the scroll from a task gated on the row being in the list
  (`when ... and lastKey == sentKey`, `after(1, ...)`). about twenty minutes. what would help: a
  scroll to a key that is not in the list yet waits one commit for it, or the drive log and the
  runtime name the missing key ("scrollIntoView: no row with key ... in list ...").
- the chat recipe says "a send scrolls to the end" with `scrollIntoView(..., lastId, block="end")`
  in the mutation's `then`. it does not say that a call in the sending action itself cannot see the
  optimistic row, which is where an app that animates the send has to call it.
- an app cannot wait for "the smooth scroll ended". the flight start polls a state that the list's
  scroll event keeps (`away`) from an every-frame task, with a time limit. what would help: a
  scroll-end event, or `scrollIntoView(..., then=<action>)`.

- an action read a state that a called action had just assigned, and got the value from before
  the action. so a branch written as "if the flight is held" never ran, and another path did the
  work; the drive looked right. `contract build --errors-only` (the command the project runs after
  each edit) hides the `analyze-read-after-assign` warning that names this exactly; `verify` showed
  it an hour later. what would help: `--errors-only` still prints this warning class, since it is
  a wrong-result bug, not style.

### Lean in
- `screenshot <png> over 1800 every 150 window` showed the order of the scroll and the flight
  without a screen recording.
- a gated task (`when <state> and <derived>` plus `after(1, action)`) is a small, readable way to
  run a step when data arrives.

### Needed
- nothing blocked the task.

### Checkpoints
- sent from three screens up: the chat is at its end within 150 ms, then the bubble leaves the field.
- sent at the end: unchanged motion.
- Reduce Motion, sent from higher up: the chat goes to the sent row at once.
