# `ios --run` installs on a different simulator than the one `agent ios` uses

**Status:** Open
**Systems:** exact.mjs, ios builds, agent
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

`bun exact.mjs ios --run` installed and launched the app on a simulator other than the one named
in the app's `.exact/simulator` file. The next `agent ios --sim <udid>` (the named simulator) then
built and installed the app again. Nothing in the output said which rule picked the device for
`ios --run`.

Cost: about two minutes and one extra install, on a nearly full disk.

## What would help

- `ios --run` reads the same simulator choice as `agent ios` (the `.exact/simulator` file).
- Or `ios --run` prints which rule picked its device.

Related: [parallel sessions share the default Simulator](20261102-parallel-sessions-on-one-machine-share.md),
which is about worktrees that share one default; this one is one app folder with its own file.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator.
