# Lens: review-comments

People already left remarks about this change. What became of each one?

Remarks come from three places: the change itself (inline review threads and the general conversation on the PR or MR), a linked issue, and the ticket in the tracker. Only inline threads have a resolved state; the others are treated as unresolved.

## Signals

Used once whenever comment entries exist, from any of the three places.

## Pursue

For each comment entry, read the whole discussion, then the code it concerns as it is now. A comment on an issue or ticket has no line attached: find the code it is about through the change map.

1. **What was asked?** One sentence, in the reviewer's sense. If later replies changed the request or settled on something else, the agreed outcome is what counts.
2. **How did the discussion end?** Agreement to change, a refusal with a reason, a question left hanging, silence.
3. **What does the code do now?** Find the lines the thread referred to. They may have moved or been rewritten; follow them. Compare with what was asked or agreed.

Then give the entry one status.

Unresolved threads, and all comments without a resolved state:

| Status | When |
|---|---|
| `addressed` | The current code does what was asked, although nobody closed the thread |
| `still applies` | The code is unchanged in the respect that was raised, or changed without meeting it |
| `can't tell` | The request is too unclear, or the code it referred to can no longer be located |

Resolved threads:

| Status | When |
|---|---|
| `resolved in code` | The code does what was asked or agreed |
| `declined with reason` | Closed after the author explained why not, and nobody objected further |
| `resolved without change` | Closed, yet the code is unchanged in that respect and no reason was given |
| `resolved differently` | Closed after a change that does not do what was asked or agreed, or does it only in part, or only in one of several places |

Also look for:

- A fix made at the commented line while the same problem remains in sibling code the reviewer plainly meant as well.
- A fix that answers the remark and breaks something else. Report that under the lens it belongs to, and reference the thread.
- A later commit that undid an earlier fix for a thread.
- A ticket or issue comment that changed the scope after the work started ("also handle X", "drop Y", "do it per tenant instead"). Check the code against the comment, not against the older ticket body.
- A question someone asked about the change that nobody answered, when the answer decides whether the code is right.

## Reporting

`still applies`, `resolved without change` and `resolved differently` each become a finding: location is the current code, trigger is the reviewer's request, consequence is what remains unmet. Score it by what was asked for, not by the fact that a comment was skipped: an unmet correctness or security remark takes the impact and likelihood of the defect it pointed at; an unmet wording or naming remark has impact 1.

Quote the reviewer's words exactly, in a blockquote, with their author. Do not paraphrase them into something stronger or weaker.

## Not a finding

- Whether the reviewer was right. You report what happened to the remark, not its merit. If you believe a request was mistaken, the code simply gets the status it has.
- A thread `declined with reason`. Record it and move on, even if you would have decided otherwise.
- Bot-generated threads (coverage, formatting, dependency notices) unless they flag something a lens here would report anyway.
