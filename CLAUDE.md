# skills

Agent skills published for `npx skills` and as a Claude Code plugin marketplace. One directory per skill; `SKILL.md` is the entry point and everything it references is resolved relative to that directory.

- A new skill needs an entry in `.claude-plugin/marketplace.json` (`"strict": false`, `"skills": ["./<name>"]`) and a row in `README.md`. Skill directories stay at the repo root: `npx skills` relies on that layout.
- Each skill has its own semver version, in two places that must match: `metadata.version` in its `SKILL.md` frontmatter and `version` on its plugin entry in `marketplace.json`. Bump the version every time anything in a skill's directory changes, however small (a typo, a lens, a script), in the same commit, in both places: patch for wording and fixes, minor for new behaviour, major when the user-facing format or data layout changes. Claude Code only offers a plugin update when its version changes, so a missed bump leaves users on the old copy.
- Some files are deliberately duplicated across skills, because each skill is installed on its own and can only read its own directory (today: `protocol/connections.md` in `better-code-review` and `help-me-understand`). When you change one copy, make the same change in every other copy in the same commit, and bump the version of every skill whose copy changed. Never let copies differ, and never fix a difference by editing only one side: work out which text is right, then apply it to all. A new duplicated file gets a `cmp` line under Verify.

## Public repo

This repo is public, and so is its whole git history: anything pushed stays readable even after a later commit removes it.

- Never commit secrets: tokens, passwords, API keys, cookies, private keys, `.env` files.
- Never commit company-specific or internal material: employer or client names, internal hostnames and URLs, private repo or org names, ticket keys and their contents, code or diffs from private repos, real review reports.
- Never commit personal data: real names, emails, usernames or home-directory paths other than the author's public GitHub identity.
- Examples and fixtures use invented names (`acme`, `example.com`, `ABC-123`), never something copied from real work.
- This applies to commit messages, branch names and file names too, not only file contents.
- Before every commit, read the staged diff for the above. If something sensitive is already committed or pushed, stop and say so; don't try to fix it by rewriting history on your own.

## better-code-review

- `SKILL.md` is the orchestrator (steps 1-10). `protocol/probe.md` is what every probe follows, `protocol/challenge.md` what every challenger follows, `protocol/report.md` the report template, `protocol/connections.md` the connection-file format. `lenses/<name>.md` describes one way code breaks, in three fixed sections: Signals, Pursue, Not a finding.
- One contract, change together: the finding fields, the impact × likelihood scales, score bands and severity/grade words in `probe.md` (defined there only), the verdicts in `challenge.md`, the template and status words in `report.md`, and steps 8-10 of `SKILL.md`. Adding or renaming a lens also touches the lens table in `README.md`.
- The challenger must never receive a probe's reasoning, only location, trigger and consequence. That blindness is the false-positive defence; don't weaken it for convenience.
- Comments from the change (review threads, resolved or not, and the PR conversation), linked issues and the ticket are fetched verbatim and matched against current code with the statuses in `lenses/review-comments.md`. The skill reports what happened to a remark and never rules on whether the reviewer was right.
- The `necessity` lens questions whether the change needs to exist. It checks facts in the code, never product decisions, and its findings go through the challenge like any other.
- The report format is versioned (`<!-- better-code-review:report schema=N -->`). Changing sections, ID prefixes or status words means raising N in `report.md`; older reports are then skipped on comparison.
- `scripts/collect-context.sh` takes no arguments on purpose (its only input is a validated `BCR_BASE`) and treats the origin URL and branch name as untrusted: anything that becomes a path goes through `to_slug`. It never runs external diff drivers or textconv filters.
- `~/.skillbox-data/` is a user-facing layout shared by every skillbox repo: `<skill>/` per skill (here `better-code-review/reports/`, `better-code-review/context/`) and `connections/` shared by all skills. Moving or reshaping it orphans users' reports, context and connections. Nothing written there may ever contain a secret value.
- The connection-file format is a contract between skills, possibly in other skillbox repos. Each skill that uses connections carries its own copy of `protocol/connections.md`; keep the copies identical. Skills add missing recipes and repair failing ones, never rewrite or remove working ones.
- Skills must stay harness-neutral (Claude Code, Codex, OpenCode, Copilot): no tool names without the alternatives, no hardcoded install paths.
- The copy agents actually load is the installed one (`~/.agents/skills/better-code-review`), not this checkout. Reinstall after changes before judging behaviour.

## help-me-understand

- One file, `SKILL.md`, plus its copy of `protocol/connections.md` (identical to the one in `better-code-review`).
- The card's sections, icons and order are the user-facing format, and the saved-file header is versioned (`<!-- help-me-understand:explanation schema=N -->`). Changing either means raising N; older saved explanations are then treated as not found.
- Saved explanations live in `~/.skillbox-data/help-me-understand/<kind>/<name>.md`, one folder per kind (coding: `ticket`, `change`, `code`, `concept`; everything else: `topic`), with `index.md` over all of them. Adding or renaming a kind touches the two tables in step 1, the name table in step 2, the tables in step 3, the header in step 5 and the folder list, together. The name rule (letters, digits, dots, dashes, 80 characters) is what keeps ticket keys, branch names and URLs from becoming paths; don't loosen it.
- The skill only explains: it never edits code or writes to a ticket or change, and it does not trace errors.

## Verify

- Marketplace: `claude plugin validate . --strict`.
- Versions: for every skill directory in the staged diff, its `SKILL.md` `metadata.version` was raised and matches its `version` in `marketplace.json`.
- Connections: `cmp better-code-review/protocol/connections.md help-me-understand/protocol/connections.md` prints nothing.

- Script: `bash -n better-code-review/scripts/collect-context.sh`, then run it inside a scratch git repo with `HOME` pointed at a temp dir and read its output. Delete the `bcr-*` temp directory it names in `workdir=`.
