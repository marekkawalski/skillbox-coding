# Lens: race-conditions

What if this runs twice at once, or in a different order than the author pictured?

## Signals

- Shared mutable state: module-level variables, caches, singletons, static fields, files, rows read and then written.
- Threads, async tasks, workers, schedulers, event handlers, request handlers added or changed.
- Check-then-act sequences, read-modify-write on stored data, counters, uniqueness checks done in application code.
- Transactions, locks, queues, retries, webhooks or message consumers touched by the change.

## Pursue

- Pick two actors and interleave them by hand at each point where one can be suspended: between a check and its use, between a read and a write, across an `await`. Write the interleaving down; that is your trigger.
- Delivery more than once: duplicate requests, redelivered messages, a retried job. Is the operation safe to repeat, or guarded by something that makes it so?
- Transaction boundaries: is everything that must be atomic inside one, and is anything slow or external inside one that should not be?
- Lock scope and order: held across I/O, taken in different orders on different paths, released on every exit?
- Ordering assumptions: events arriving late or out of order, a callback firing after teardown, initialisation racing first use.
- Visibility: a value written by one thread and read by another without the synchronisation the language requires.
- Unawaited or fire-and-forget work whose failure or timing matters.

## Not a finding

- A race that needs two actors where the design guarantees one (a single-threaded runtime section with no suspension point, a job with an enforced singleton lock). Verify the guarantee.
- Theoretical interleavings with no consequence beyond a harmless repeated read.
