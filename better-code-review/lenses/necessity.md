# Lens: necessity

Every other lens asks whether the change is done right. This one asks whether it should have been done. A change can follow its ticket to the letter while the ticket itself is mistaken.

## Signals

Always used, once per review. With reconstructed intent it still runs, on the derived requirements.

## Pursue

Look at the code **as it was before the change** (read files at the merge base, not only the diff) and test each requirement's premise:

- **Is the problem real?** If the ticket reports a defect, find the path that produces it in the old code. If the old code already behaved as requested, or the described situation cannot occur, say so with the lines that show it.
- **Does it already exist?** Search for an existing function, option, flag, endpoint, setting or library feature that does what was asked. A second implementation of something the system already offers is the finding.
- **Is the assumption about the system true?** Tickets state how things work ("the job runs hourly", "this field is never empty", "clients cache this"). Check each stated fact the change depends on against the code and configuration.
- **Does it contradict something?** Another requirement in the same ledger, documented behaviour, a test that pins the opposite on purpose, a recorded decision in the repository or the user's context.
- **Is it the wrong layer or the wrong remedy?** The symptom is treated where it shows instead of where it starts; the same result is available by configuration, by deleting code, or by using what exists.
- **Is anyone on the other end?** New code with no caller, no route to it, no consumer of what it emits, and no requirement saying one is coming.
- **Does the change outgrow its reason?** A small need answered with a framework, an extension point or options nobody asked for.

## Reporting

Give every requirement one of `sound`, `doubtful`, `unfounded`, with one line of evidence.

A premise problem is reported as an ordinary finding, with the fields read this way:

- **location**: the existing code or configuration that makes the requirement moot, wrong or redundant
- **trigger**: the assumption the requirement rests on, quoted or closely restated
- **consequence**: what building it costs: duplicate behaviour to keep in step, a fix for a problem that does not occur, a contradiction now shipped

Scoring: likelihood is 5 for an `unfounded` requirement, because the cost is paid on every merge, and impact is 4 or 5 by how much of the change need not exist. That makes it `Critical`. A `doubtful` premise with a stated, checkable reason scores in the `Medium` range.

## Not a finding

- Disagreement with a product decision. Whether a feature is worth having is not yours to judge; whether the facts it was justified with are true is.
- A premise you could not check because the facts live outside the code (user research, a contract, a production incident). Mark it `sound` if nothing contradicts it and note that it was not checkable.
- "Could have been simpler" without an existing, named alternative that already does the job.

Be exact and modest here. Telling someone their ticket was pointless is a serious statement; make it only with the lines that prove it, and expect to be challenged.
