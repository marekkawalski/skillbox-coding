# Lens: data-compatibility

Stored and transmitted data outlives the code that wrote it. Does the new code agree with the old data, and the old code with the new data?

## Signals

- Schema changes, migrations, index changes, new constraints.
- Changed serialised shapes: API payloads, events, messages, cache entries, files on disk, cookies, stored JSON.
- Changed meaning of an existing field: unit, nullability, allowed values, format.
- Backfills, bulk updates, deletes, anything irreversible.

## Pursue

- Rows and records written before this change: can the new code read every one of them? Look for new required fields, tightened validation and removed enum members.
- During rollout both versions run. Can old code read what new code writes, and the reverse? What happens to in-flight messages and cached entries?
- Migration safety: does it lock a large table, rewrite it, or run a long transaction? Is there a way back, and does going back lose data?
- Order of operations: is a column used before it exists, or dropped while still read? Does the migration assume the code is already deployed, or the code that the migration ran?
- Constraints and defaults: do existing rows satisfy the new constraint? Is the default right for old rows or only for new ones?
- Deletes and updates: is the filter as narrow as intended? What does it do with an empty or missing parameter?
- Precision and encoding: money in floats, timestamps without zone, truncating column lengths, text encoding, large integers through JSON.
- Integrity that the application now enforces instead of the store, or the other way round.

## Not a finding

- Compatibility with consumers that provably do not exist yet (an endpoint or table introduced in this same change).
- Migration concerns on a table the project documents as small or disposable.
