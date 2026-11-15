# Lens: project-rules

Every project has rules it wrote down for itself. Does the change follow them?

## Signals

- The repository has instruction files for agents or contributors, architecture notes, a style guide, or linter and formatter configuration with project-specific rules.
- The user's context files state preferences for this repository.
- The change adds a kind of thing the rules speak about: a dependency, an endpoint, a migration, a module, a public API, a log statement, a test.

## Pursue

- Collect the written rules that apply to the touched paths. Rules in a nested directory override the ones above it for files beneath it.
- For each changed file, check the rules that concern its kind of change. Quote the rule and name where it is written.
- Required companions: does the project demand a changelog entry, a documentation update, a registered route, a migration note, a test of a certain kind alongside this sort of change?
- Layering and boundaries the project declares: does the change import across one, or put logic in a layer that is meant to stay thin?
- Conventions visible only in the code: when no rule is written, compare with how neighbouring files do the same thing. A departure from a consistent local pattern is worth a `Low` note, and only that.

## Not a finding

- Anything without a rule you can quote or a local pattern you can point to. General best practice is not a house rule.
- Rules that automated checks in the project already enforce; if the check passes, do not repeat it.
- A rule the change breaks on purpose with the reason stated in the change itself. Mention it once as a note for the reader.

Score a violation by what the rule protects: one guarding correctness, security or compatibility takes the impact of what it prevents; a convention about form has impact 1.
