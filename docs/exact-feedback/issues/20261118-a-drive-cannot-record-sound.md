# A drive cannot record sound, and no doc says so

**Status:** Open
**Systems:** agent drive (iOS), docs
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

In a drive, a press on an app's record control (`getUserMedia` for audio, then a media recorder)
leaves the app waiting on the microphone. The simulator's microphone permission was granted with
`simctl privacy`. No error arrives; the app's state stays at its first step. So the screen that
follows a recording (a draft's player) cannot be driven.

Cost: two drives.

## What would help

A doc line on whether a drive can open the microphone, and how; or a failure the app can show.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`, iOS Simulator, under `--touch platform`.
