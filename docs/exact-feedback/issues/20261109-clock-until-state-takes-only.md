# `clock until state` takes only `==`; `!=` is refused

**Status:** Open
**Author:** Devin, from an external app friction log
**Systems:** agent drive
**Severity:** P3
**Date:** 2026-11-09

Waiting for a value to become non-empty reads naturally as
`clock until state openRoom != "" within 45000`. The op is refused: only
`== <literal>` parses. Waiting for *absence* of a value needs `clock data` +
`clock +N` and a later `state` read.

Cost: two refused ops across two drives. What would help: `!=` accepted for the
same literal set, or the refusal naming the supported operators.

Additional evidence (2026-11-18, exact2 `b46687753f`): `clock until state <path> != "" within <ms>` was refused again; the error named the accepted `==` form. The refused op ended the drive before a sign-in finished, so the next drive started signed out. About one minute and one drive. "Wait until a value arrives" after a sign-in is the common case for `!=` or a "not empty" form.
