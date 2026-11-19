# A computed `vertical-align` fails only in the web target's check, reported against `app.ts` line 0

**Status:** Open
**Systems:** contract compiler (JS target), typescript-check
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A computed `vertical-align` on an inline image built for iOS, then failed only in the web
target's check: "a dynamic `vertical_align` (Enum) is not one declaration; not in the JS target".
It was reported as a `typescript-check` error in `app.ts` line 0, not at the contract line that
held the expression. The fix was two `if` branches, each with a literal value.

Cost: a few minutes.

## What would help

- The error points to the contract line that holds the computed value.
- The message, or the vocab entry, says which properties may be computed on every target.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`.
