# `scale` takes one number; a one-axis scale has no documented form

**Status:** Open
**Systems:** compiler, docs (motion)
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

`scale="1 1.15"` (taller, not wider) is refused: "is not a valid `scale`: expected number". CSS
accepts two values. No doc line names another way to scale one axis, so the effect was dropped.

Cost: one build.

## What would help

A two-value `scale`, as CSS has, or the error naming the alternative.

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`.
