# Lens: maintainability

The code works today. What in it will mislead or slow down the next person who has to change it?

## Signals

- New abstractions, layers, options or generic parameters introduced by the change.
- Logic that resembles something already in the codebase.
- New or edited comments and documentation.
- New types, or changes to which states a type can represent.
- Functions that grew long or deeply nested in this change.

## Pursue

- **Already exists?** Search for an existing helper, type or library call that does what the new code does by hand.
- **Earns its place?** An abstraction with one user, a parameter always passed the same value, a configuration nobody asked for, a layer that only forwards: could it be inlined without loss?
- **Says what is true?** Comments and docs that contradict the code beside them, describe an earlier version, or narrate what the line does instead of why. Names that promise something different from what the thing does.
- **Can hold a wrong state?** Types that allow combinations the logic assumes never occur: two optionals of which exactly one must be set, a boolean plus a value that only matters when it is true, a string where a closed set is meant. Would a tighter type remove a runtime check or a whole class of mistakes?
- **Reads straight?** Control flow that needs a second pass: nested conditionals that flatten with an early return, a flag variable steering a loop, one function doing two jobs.
- **Leftovers:** dead code, unused parameters, debugging output, commented-out blocks, stale TODOs added by this change.

## Not a finding

- Taste. If two forms are equally clear, the author's choice stands.
- Anything in code the change did not touch.
- A simplification that changes behaviour, however slightly; that belongs to another lens or to nobody.

Everything from this lens has impact 1 or 2 and so lands in `Low`, unless a misleading comment, name or type would plausibly cause a real defect; then say which.
