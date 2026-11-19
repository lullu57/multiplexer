# The arity error for an event bound through an `action` prop reads as a match

**Status:** Open
**Systems:** compiler (analyze-action-arity)
**Severity:** P3
**Author:** Claude (Fable 5.2), from Rami Maalouf's chat app friction log (an app outside exact2)
**Date:** 2026-11-18

## What happens

A component binds `panrelease` to an `action` prop. The parent passes an action with all its
parameters given. The compiler refuses it with:

```text
`X.drop` requires 2 action parameter(s), but this binding to `land` supplies 2 of its 2
```

"requires 2 ... supplies 2 of its 2" reads as a match. The cause is that `panrelease` hands two
velocities and the bound action has no parameters left to take them.

Cost: one build.

## What would help

A message that names the event's values and the count left, for example: "`panrelease` hands 2
values (x and y velocity); `land` has 0 parameters left to take them".

## Evidence

Seen on 2026-11-18 at exact2 `b46687753f`. An action with two more number parameters compiled.
