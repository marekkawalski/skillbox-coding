# Lens: error-handling

What happens when the thing this code calls does not work?

## Signals

- New or changed I/O: network, disk, database, queue, subprocess, clock.
- New or changed error handling: catch blocks, error returns, fallbacks, retries, default values on failure.
- Multi-step operations where a later step can fail after an earlier one took effect.
- Resources that must be released: handles, locks, transactions, temporary files, subscriptions.

## Pursue

- For each call that can fail, name the failure and follow it. Who learns about it: the caller, the user, the operator, nobody?
- Errors turned into silence: an empty catch, a caught error replaced by a default, a logged-and-continued failure, an ignored return value or rejected promise. What does the system then believe that is not true?
- Catches wider than the failure they were written for, which also swallow programming mistakes.
- Fallbacks: is the fallback value distinguishable from a real result downstream? Would anyone notice it is being used every time?
- Partial completion: after step two of three fails, what state is left behind, and does a retry repair it or repeat it?
- Cleanup on every exit: early returns, exceptions, cancellation, timeouts.
- Timeouts and retries: is there a bound? Does a retry repeat a non-idempotent action? Can retries pile up under load?
- Error text: does it say what failed and with which input, without leaking secrets or internals to an end user?

## Not a finding

- An error deliberately ignored with a stated reason that holds (best-effort cleanup, optional telemetry).
- A failure handled one level up; read the caller before reporting it missing.
- The absence of handling for failures the platform already turns into a safe, visible crash, when crashing is the project's stated policy.
