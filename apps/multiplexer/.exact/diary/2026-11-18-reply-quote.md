surfaces: ios
agent: claude fable 5.2
task: keep a long link inside a chat app's reply bar and reply quote, and open the quoted message on a tap

### Rough
- a drive step `clock until state <path> != "" within <ms>` was refused: only `==` with a literal
  is accepted. the error named the accepted form, so it cost one drive (about one minute), but the
  refused op ended the drive before a sign-in finished, and the next drive started signed out. what
  would help: accept `!=`, or a "not empty" form, since "wait until a value arrives" is the common
  case after a sign-in.
- `ios --run` installed and launched the app on a simulator other than the one named in the app's
  `.exact/simulator` file. the next `agent ios --sim <udid>` then built and installed again on the
  named one. about two minutes and one extra install on a nearly full disk. what would help:
  `ios --run` reads the same simulator choice as `agent ios`, or prints which rule picked the device.
- after two sign-in drives, `.exact/runs.jsonl` held the typed password again (masked in the
  terminal output). redacted by hand after each drive. this is a known finding; new evidence only.
- the quoted text in a reply bar ran past its column and under the close button with a long link,
  although the column had `min-width=0` and the text had `line-clamp`. the pitfalls page names the
  fix (`overflow-wrap="anywhere"`), and it worked the first time. the sample chat app's reply bar
  and quote have the same two texts without it. what would help: `check`, or the compiler, naming a
  `line-clamp` text of app data that has no `overflow-wrap`.

### Lean in
- a component with an `action` prop let one card serve the reply bar and the edit bar, and the
  existing "go to a found message" tasks served the tap on a quote with five lines of new code.
- `tap <target> contextmenu` plus `screenshot <png> over 400 every 50 window` proved that a menu
  appears complete in its first frame.

### Needed
- nothing new from the framework for this task.

### Checkpoints
- reply bar: one line, ellipsis, inside the card, light and dark, keyboard up.
- quote card above the reply's bubble: two lines, ellipsis, light and dark.
- a tap on the quote of a message far back paged the chat to it and marked it.
