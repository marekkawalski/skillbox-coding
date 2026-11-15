# Lens: test-gaps

Tests are the change's own evidence. Would they notice if the change were wrong?

## Signals

Used whenever behaviour changed, whether or not the diff contains tests.

## Pursue

- **The revert question.** For each requirement, imagine the production change undone while the tests stay. Which test fails? If none would, the requirement is unproven, however many tests were added.
- **The mutation question.** Flip a condition, drop a line, change a boundary in the new code in your head. Is there a test that would catch it? Name the mutation that survives.
- Does each test assert on the outcome that matters, or only that something ran, that no exception was thrown, or that a mock was called?
- Mocks and stubs: is the test exercising the new code or a stand-in for it? Does a mock encode an assumption about a dependency that the change map shows is no longer true?
- Paths without a test: error branches, boundaries, the "nothing to do" case, the concurrent or repeated call, the old data shape.
- Changed or deleted tests: was an assertion weakened, an expectation updated to match new output without anyone asking whether the new output is right, a test disabled?
- Tests for dependents: when a contract changed, do the callers' tests cover the new contract or still run against the old shape through fixtures?
- Reliability: dependence on real time, ordering, shared state, network or random values without a fixed seed.
- If the project's tests can be run cheaply, run the relevant ones and report the result as it is.

## Not a finding

- Missing tests for code without behaviour (constants, wiring, pure renames).
- A coverage percentage. Only named, unprotected behaviour counts.
- Test style that differs from yours but follows the project's existing tests.
