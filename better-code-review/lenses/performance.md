# Lens: performance

Will this still be acceptable when the input is as large and the traffic as heavy as production makes them?

## Signals

- A query, request or file operation inside a loop, or inside something called from a loop.
- Work on collections that grow with users, rows or time; nested iteration over them.
- New code on a path that runs per request, per row, per render or per event.
- Unbounded fetches, missing pagination or limits, whole-file or whole-table reads.
- Caches, memoisation, pools, batching or indexes added, removed or bypassed.

## Pursue

- Put a number on it. How many items in practice, how many calls per item, how often does the path run? A finding needs a realistic size at which it hurts, not just a complexity class.
- Round trips: can N calls become one, by batching, joining or loading up front?
- Queries: does the filter have an index behind it, does it select more columns or rows than used, does sorting or counting scan everything?
- Repeated work: the same value computed, parsed, compiled or fetched again on every iteration or call when it could be done once.
- Memory: growth with input size, collections that are never trimmed, large objects kept alive by closures or caches without eviction.
- Blocking: slow or synchronous work on a thread or loop that must stay responsive; a lock held while waiting on I/O.
- Caches: is the key complete, is stale data acceptable, what invalidates it, what happens when many callers miss at once?
- Startup and build cost if the change runs there.

## Not a finding

- Inefficiency on a path that runs rarely over small, bounded data. Say why it is bounded.
- Micro-optimisations with no measurable effect at realistic sizes.
- Speed traded knowingly for clarity, where a comment or the project's context says so.
