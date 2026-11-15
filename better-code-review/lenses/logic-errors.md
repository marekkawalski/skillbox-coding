# Lens: logic-errors

Does the changed code do what its requirement says, for every input it can receive?

## Signals

Used for every changed element that has behaviour. No signal needed.

## Pursue

- State the intended behaviour in one sentence, then read the code as if you had not been told it. Do the two match? Where they differ, which one is wrong?
- Walk the boundaries of each input: empty, one element, the maximum, zero, negative, absent, duplicated, unsorted, wrong case, surrounding whitespace, non-ASCII, a value just past each comparison in the code.
- Conditions: is every branch reachable, is any branch missing, are `and`/`or` and negations the right way round, do ranges include or exclude their ends as intended?
- Loops and indexes: first and last iteration, an empty collection, mutation of the collection being walked.
- Values that changed type or unit on the way: seconds and milliseconds, cents and currency units, local and UTC time, characters and bytes, inclusive and exclusive ends.
- State carried between calls: what happens on the second call, after a failure halfway, after a retry?
- Defaults: when the caller passes nothing, is the default the old behaviour or a new one?
- Copy-and-adapt code: is every occurrence of the copied name actually adapted?

## Not a finding

- An input the type system, a schema or validated entry points make impossible. Check before claiming it can arrive.
- Behaviour that differs from what you would have designed but matches the requirement.
- A boundary the same function handled identically before the change, unless the change makes it reachable.
