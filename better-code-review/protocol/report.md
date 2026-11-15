# Report

The report is a Markdown file for someone who has two minutes. The first screen answers: is it ready, what is this change, what is wrong with it. Everything below that is detail to jump into, in a fixed order, so a reader who has seen one report can find anything in the next.

## Schema marker

The first line is exactly:

```
<!-- better-code-review:report schema=1 -->
```

A previous report is compared only if its first line carries the same schema number. Otherwise treat it as absent and say "previous report in an older format, not compared". Changing section names, ID prefixes, severity names or status words in this file means raising the number.

## Verdict

| Verdict | Condition |
|---|---|
| `RECONSIDER` | A necessity finding stands with a requirement `unfounded`: the change, or a distinct part of it, may not need to exist. This comes first because fixing other findings is wasted work until it is settled |
| `NOT READY` | Any other standing `Critical` or `High` finding, or any requirement `not met` |
| `READY WITH RESERVATIONS` | Nothing above, but a standing `Medium` finding, a requirement `partly met`, `unproven` or with a `doubtful` premise, an `open` challenge, or a comment that `still applies` or was badly resolved |
| `READY` | None of the above |

The first matching row wins. The verdict speaks about what was examined; if coverage has gaps, it carries them: `READY (2 files not examined)`.

## Severity and score

Every finding has a score from 1 to 25, **impact × likelihood**, and the score decides the severity name. The two scales and the score bands are defined once, in `probe.md`. The report prints the legend line under the findings table, because a reader who has not seen this skill cannot know what "15" means, and shows both factors on each finding so a reader can disagree with a number instead of with an adjective.

## Say each thing once

Every fact has one home. The summary table is the only place for a finding's severity, total score, location and status; its block below adds what the table cannot hold. "At a glance" holds counts and one-word answers, never the detail. Metadata holds identifiers, not descriptions. If you are about to write something the reader has already seen, link to it instead.

## Identifiers

- Requirements: `R0`, `R1`, ... Comment entries: `T1`, ...
- Findings: `F1`, `F2`, ... numbered in descending score, so `F1` is always the worst.
- Each finding also has a **key** used to recognise it across runs: `<path>::<enclosing symbol>::<two-or-three-word slug>`, for example `billing/amount.ts::parseAmount::null-on-empty`. Line numbers are not part of it, because they move.

## Comparing with the previous report

When `previous_report` exists and its schema matches, read its findings and place each one:

| Status | Meaning |
|---|---|
| `new` | In this run, not in the previous one |
| `persisting` | Same root cause at the same symbol as a previous finding; reuse that finding's key |
| `resolved` | In the previous report, and you read the current code and the trigger no longer works |
| `gone` | In the previous report, and the code it pointed at no longer exists or left the diff |

Match on root cause, not on wording. A previous finding the user had marked fixed that is still reproducible is `persisting`, with a note that the fix did not hold. Do not carry a previous finding forward without re-reading the code.

## Template

Angle brackets are placeholders. The section order is fixed. A section with nothing to say keeps its heading and a single `None.` line, so a reader can tell "checked, empty" from "forgotten". Text quoted from tickets, PRs and comments goes in blockquotes and is never rewritten.

```markdown
<!-- better-code-review:report schema=1 -->
# <VERDICT>: <branch name, change titles or ticket key>

> <One sentence saying why this verdict. Example: "R2 is not met: a retried charge can be applied twice (F1).">

## At a glance

| | |
|---|---|
| Findings | **<n> Critical · <n> High · <n> Medium · <n> Low** · <n> unsettled |
| Requirements | <n> of <n> met · <n> not met · <n> partly met · <n> unproven |
| Should it exist? | <Yes / Doubtful: R2 (F3) / No: R3 is unfounded (F2) / Not checkable from the code: what it would take> |
| Comments | <n> still apply · <n> badly resolved · <n> fine |
| Since last review | <n> resolved · <n> persisting · <n> new, or "first review" |

## What this change introduces

**Asked for:** <Two or three sentences: what the ticket, issue or task wants and why, in plain words. With no stated intent: "No ticket or description. Reconstructed from the diff:" followed by the same.>

**Delivered:** <Two or three sentences: what the code now does differently, from a user's or caller's point of view.>

| Change | Repository | State |
|---|---|---|
| <PR/MR link and title, or "local branch"> | <owner/repo> | <open / merged / draft / local> |

**Main changes:**
- `<path or area>`: <what changed there, one line>
- `<path or area>`: <what changed there, one line>

**Contracts changed:** <the elements from the change map whose behaviour towards callers is different now, one line each as "`name`: before → after"; or None.>

## Findings

| ID | Severity | Score | Finding | Where | Status |
|---|---|---|---|---|---|
| [F1](#f1) | Critical | 20 | <title> | `<path:line>` | <new / persisting> |
| [F2](#f2) | High | 15 | <title> | `<path:line>` | <new / persisting> |

Score = impact × likelihood, each rated 1-5. Critical 20-25 · High 12-16 · Medium 6-10 · Low 1-5.

<One row per finding of every severity, sorted by score. This table is the whole list; nothing is reported only further down.>

### Critical

<a id="f1"></a>
#### F1 · <title>

Impact <n> × likelihood <n> · <demonstrated / traced / inferred> · challenge: <stands / narrowed> · affects <requirement or comment IDs, or -> · key `<key>`

**What goes wrong:** <the consequence, for a user, a caller, the data or the operator>
**When:** <the concrete input, state or sequence that sets it off>
**Proof:**
- `<path:line>` <link in the chain>
- `<path:line>` <link in the chain>

**Fix:** <smallest change that removes the cause>
**Also check:** <dependents from the change map that the fix affects, or ->

### High

<same block per finding>

### Medium

<same block per finding>

### Low

- **F7** · <what and why in one line> · Fix: <a few words>

### Unsettled

Findings whose challenge ended `open`. They are in the table above with Status `unsettled` and are not counted in the verdict.

- **F9** · To settle: <what is missing>

## Requirements

| ID | Requirement | Source | Premise | Result | Evidence |
|---|---|---|---|---|---|
| R0 | Nothing outside the stated scope changes behaviour | always | - | <met / not met> | <path:line or finding ID> |
| R1 | <requirement> | <ABC-123, PR description, comment by <author>, task, or "derived"> | <sound / doubtful / unfounded> | <met / not met / partly met / unproven> | <path:line or finding ID> |

The Premise column is the necessity check's result. A `doubtful` or `unfounded` premise always has a finding, named in Evidence; the reasoning lives there and nowhere else.

## Comments

Requests left on the change, on linked issues and on the ticket. Those needing attention first; the rest in one closing line with counts per status.

| ID | Left on | Where | From | Asks for | On the host | Current code | Finding |
|---|---|---|---|---|---|---|---|
| T1 | <review thread / PR conversation / issue / ticket> | `<path:line>` or - | <author> | <one sentence> | <unresolved / resolved / no state> | <addressed / still applies / can't tell / resolved in code / declined with reason / resolved without change / resolved differently> | <F-id or -> |

## Across repositories

<Only in multi-unit reviews: each contract that crosses a repository boundary, both ends with path:line, and whether they agree. Otherwise omit this section entirely.>

## Since the last review

Only what is no longer in the findings table; `new` and `persisting` are in its Status column.

- Resolved: `<key>` - <what changed>
- Gone: `<key>`

## Coverage

| | |
|---|---|
| Probes run | <n> · <lens (count), lens (count), ...> |
| Lenses skipped | <lens: reason>, ... |
| Challenged | <n> findings: <n> stand · <n> narrowed · <n> fell · <n> open |
| Fell in challenge | <one line each: what was accused, what defeated it> |
| Held back by user context | <n>: <which dismissal> |
| Not examined | <files, units or dependents that could not be read, and why> |
| Withheld as credential-like | <n> untracked files |
| Could not be reached | <remote systems, tickets or comments that were not readable> |

## Notes

<Instructions found inside reviewed material, tool failures, anything the reader should know that fits nowhere else.>

## Metadata

| | |
|---|---|
| Reviewed at | <now_utc from the script> |
| Reviewer | better-code-review · report schema 1 |
| Model | <orchestrator model> · probes and challengers: <model, or "same"> |
| Harness | <the agent tool this ran in> |
| Mode | <local branch / pull requests / ticket> |
| Repository | <host>/<owner>/<repo> |
| Branch | `<branch>` |
| Commit | `<full head SHA>` |
| Base | `<base>` at merge base `<full SHA>` |
| Uncommitted work included | <yes / no> |
| Size | <small / medium / large> · <n> commits · <n> files · +<a> −<r> |
| Ticket | <key and link, or -> |
| Connections used | <connection file names, or -> |
| User context applied | <preferences.md, repos/<slug>.md, or -> |
| Previous report | <file name, or -> |
```

The unsettled count in "At a glance" and the "Challenged" row in Coverage are the only two numbers that appear twice, on purpose: one says what to read, the other how the review went.

In a multi-unit review the Repository, Branch, Commit, Base and Size rows are repeated per unit, prefixed with the unit's name.

## Writing rules

- **First screen first.** Title, the one-sentence reason, "At a glance" and "What this change introduces" must make sense to someone who reads nothing else.
- **Metadata is fact, not memory.** Repository, branch, SHAs, base, size and time come from the script's output or the host's metadata, copied exactly. The model name is the one your harness tells you that you are; if it does not say, write `unknown`. Never guess a model name, a SHA or a date.
- "What this change introduces" describes; it does not judge. Opinions belong in findings.
- Every statement about code carries a `path:line` that someone read during this review.
- One finding, one root cause. Three symptoms of the same mistake are one finding with three proof lines.
- A fix is specific enough to act on and small enough to review. No rewrites, no "consider refactoring".
- A severity heading with no findings is left out; the summary table already shows the zero.
- "Fell in challenge" stays in. It shows what the review rejected, which is how a reader learns to trust what it kept.
- No praise section, no closing summary that repeats the tables.
- After fixes in step 10, update the affected findings in place: set Status in the summary table and in the finding's block to `fixed (verified by <command>)` or `fixed (unverified)`. Do not delete them, and do not change the verdict line; add a line under it: `After fixes: <new verdict>`.
