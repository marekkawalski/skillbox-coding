# Lens: security

Where does data or a request cross from someone who is not trusted to something that matters?

## Signals

- New or changed entry points: routes, handlers, RPC methods, message consumers, CLI arguments, file uploads, webhooks.
- Outside input reaching a query, a command line, a file path, a template, a deserialiser, a redirect, a URL to fetch, a log line.
- Changes to authentication, sessions, permissions, roles, tenancy or ownership checks.
- Secrets, keys, tokens, cryptography, randomness, cookies, CORS or security headers touched.
- New dependencies, or code that downloads and runs something.

## Pursue

- Trace each outside value from where it enters to where it is used. Is it validated or encoded for *that* use before it gets there? Name the sink and the missing step.
- For each new action, ask who may perform it and on which objects. Is the check on the server, on every path to the action, and does it compare against the owner or tenant of the specific object rather than merely "is logged in"?
- Identifiers taken from the request: can a caller substitute another user's?
- What leaves the system: fields added to responses, logs, error messages, analytics. Any secret, personal data or internal detail among them?
- Secrets: hard-coded, committed in fixtures, written to logs, compared in non-constant time, generated with a non-cryptographic source.
- Limits: can an outside caller make this allocate, loop, fetch or store without bound?
- Defaults: does the new setting fail closed when it is absent or malformed?

## Not a finding

- Input that only an already fully trusted actor can supply, when that trust is the documented model.
- A missing defence that the framework applies automatically in this configuration. Confirm the configuration.
- Generic hardening advice with no path from an attacker to a consequence in this change.
