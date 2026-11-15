# Lens: broken-callers

The diff shows what was edited. This lens asks who was relying on the way it used to be.

## Signals

- A changed signature, return shape, raised error, default, ordering or side effect on anything used outside the diff.
- A renamed or removed symbol, route, event, config key, flag, column or message field.
- A contract that crosses a repository or service boundary.
- An interface or base type changed while implementers or subclasses were not.

## Pursue

- For each dependent listed in the change map, open it and read how it uses the element. Does it still hold under the new contract? Pay attention to dependents the diff did *not* touch: those are the ones nobody looked at.
- Search again yourself, more widely than by name: string references, reflection, dependency-injection wiring, templates, configuration files, SQL, scripts, CI definitions, documentation with runnable examples.
- Values that used to be impossible: a return that can now be null, empty, negative, a new enum member, a new error type. Which consumer switches, maps or pattern matches do not know the new case?
- Implicit agreements: two places that must change together (a writer and a reader, an encoder and a decoder, a constant duplicated in a test fixture or another service). Did both change?
- Ordering between units: if one repository deploys before the other, is the intermediate state safe?
- Removed code: was anything still calling it, including from tests, jobs and other repositories in the review?

## Not a finding

- A dependent that was updated correctly in the same change.
- A caller that could break only with inputs it never passes; read the call site before claiming it.
- Missing updates to dependents you could not find. Report the search as "not examined", not as a defect.
