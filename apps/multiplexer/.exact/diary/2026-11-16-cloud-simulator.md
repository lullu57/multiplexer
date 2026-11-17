surfaces: ios
agent: claude opus 5.5
task: run the app on a remote iOS Simulator (a cloud device service) the way `bun exact.mjs ios --run` runs it locally

### Rough
- `bun exact.mjs ios --help` does not list `--no-install`, which a build for another device needs (build, install on nothing). found by reading `host/apple/build.mjs`. about 3 minutes.
- the built bundle's path is only in a prose line (`host/apple: <path> (...); built and signed, installed on nothing`), so a script that installs the build elsewhere parses that line. no `--json` names the product. about 2 minutes.
- `agent ios`, `test ios` and `verify ios` reach only a simulator on this Mac (simctl, the app's data container), so on a remote simulator the app is driven by another controller and authored tests cannot run there. about 5 minutes reading `scripts/agent-launch.mjs` and `scripts/agent-inspect.mjs` to confirm.

### Lean in
- app.json `commands` made the cloud run a verb beside `ios` (`bun exact.mjs cloud`), with no change to exact.mjs, and `bun exact.mjs help` lists it.
- the development simulator build is a plain `.app` that installs and launches on a remote simulator unchanged, with no dev server.

### Needed
- a remote device for drives (`agent ios` / `test ios` against a simulator that is not on this Mac): by hand, with the remote service's own controller.

### Checkpoints
- the development build (built in 7 s from a warm cache) installed and opened on a remote iOS Simulator; a screenshot showed the sign-in screen, and the accessibility snapshot listed its controls.
- a second run into the same remote device (rebuild, upload, relaunch) took 16 s.
