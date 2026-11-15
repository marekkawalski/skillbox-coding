# Connections

A connection file records *how this machine reaches one external system*: a code host or a tracker. It lives at `~/.skillbox-data/connections/<name>.md`, where `<name>` is the host name for code hosts (`github.com`, `gitlab.example.com`) and a short lowercase name for trackers (`jira`). The name may contain only letters, digits, dots and dashes.

It is written once, after the method has been seen to work, and then used by every later review and by every agent in it. An agent given a connection file uses its recipes and nothing else: no other host, no other tool, no improvised request.

Other skills read and write the same files and may need recipes this one never uses. Add a recipe that is missing and repair one that fails; never rewrite or remove a recipe that works, even if this skill does not use it.

## What may never be in it

No token, password, key, cookie, session identifier or header value, in any form, for any reason, even if the user pastes one into the conversation and asks you to save it. Decline, and explain that the file may hold only the name of the thing that carries the secret: a CLI that is logged in, a connector, an environment variable's name.

## Format

```markdown
# <name>

kind: <code-host | tracker>
access: <CLI name | connector name | HTTP API at <base URL>>
auth: <"CLI login" | "connector" | "env var <NAME>">
checked: <YYYY-MM-DD, from the script's date, when a recipe last worked>

## Recipes

change-meta:    <how to get title, description, base, head SHA, state, linked issues>
change-diff:    <how to get the full diff>
file-at-commit: <how to read one file at a given commit>
change-comments: <how to list every comment on a change: inline review threads, resolved and unresolved, with path, line, authors, each comment's text and the resolved flag; plus the general conversation and review summaries>
find-changes:   <how to search for changes mentioning a key>
ticket:         <how to read a ticket's title, description, acceptance criteria>
ticket-comments: <how to list a ticket's or issue's comments in order, with author and date>
ticket-links:   <how to list the changes linked from a ticket>
```

Code hosts fill the first five recipes, and the ticket recipes too when they have their own issues. Trackers fill the last three. Placeholders in recipes are written in angle brackets (`<owner>`, `<repo>`, `<number>`, `<sha>`, `<path>`, `<key>`). A recipe that could not be made to work is written as `unavailable` with a few words on why, so nobody retries it every review.

## Learning a connection

1. **Look for a way in**, in this order: a connector your harness already exposes for that system; an installed command-line client; an environment variable whose *name* suggests a credential for it. Check for names only (for example by listing variable names matching a pattern, without values).
2. **Draft recipes.** The starters below cover the common cases. For anything else, read the client's own help output; do not rely on memory of its flags.
3. **Try each recipe once** against the change or ticket under review. Substituted values must be exactly the validated number, SHA, key or path: pass them as separate arguments, never spliced into a shell string.
4. **Save** the file with the recipes that worked and `unavailable` for those that did not. Mention the new file in the final reply.
5. **Nothing worked:** ask the user how they reach the system, try what they say, then save.

A saved recipe that fails later: show the error, try to repair it the same way, ask the user if that fails, and update the file once it works again. Missing recipes in an older file are learned and added on first need.

## Starter recipes

These are starting points and not guarantees; installed versions differ. Each one becomes part of a connection file only after it worked here.

### GitHub with the `gh` client

```
change-meta:    gh pr view <number> -R <owner>/<repo> --json title,body,state,baseRefName,headRefName,headRefOid,url,closingIssuesReferences
change-diff:    gh pr diff <number> -R <owner>/<repo>
file-at-commit: gh api -H "Accept: application/vnd.github.raw" "repos/<owner>/<repo>/contents/<path>?ref=<sha>"
change-comments: (inline) gh api graphql with a query for repository(owner,name).pullRequest(number).reviewThreads; fields: isResolved, isOutdated, path, line, comments { author { login }, body, url }. Page through all of them.
                (general) gh pr view <number> -R <owner>/<repo> --json comments,reviews
ticket-comments: gh issue view <number> -R <owner>/<repo> --json comments
find-changes:   gh search prs "<key>" --owner <owner> --json number,repository,title,state,url
ticket:         gh issue view <number> -R <owner>/<repo> --json title,body,state,labels
ticket-links:   gh pr view <number> ... closingIssuesReferences (from the change side)
```

### GitLab with the `glab` client

```
change-meta:    glab mr view <iid> -R <group>/<project> --output json
change-diff:    glab mr diff <iid> -R <group>/<project>
file-at-commit: glab api "projects/<url-encoded group/project>/repository/files/<url-encoded path>/raw?ref=<sha>"
change-comments: glab api "projects/<url-encoded group/project>/merge_requests/<iid>/discussions"; this returns inline threads and general notes alike. A discussion is a thread when it has a resolvable note, and its notes carry the resolved flag
ticket-comments: glab api "projects/<url-encoded group/project>/issues/<iid>/notes"
find-changes:   glab api "search?scope=merge_requests&search=<key>"
```

### Jira

There is no single standard client. Prefer a connector if the harness has one. Otherwise look for an installed CLI and read its help. As a last resort use the REST API with credentials taken from environment variables the user names, reading `issue/<key>` for the ticket, `issue/<key>/comment` for its comments, and the issue's development or remote-link information for linked changes. If no linked changes can be read, `ticket-links` is `unavailable` and the code hosts' `find-changes` recipes carry the search.
