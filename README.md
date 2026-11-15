# skillbox-coding

Agent skills for coding, installable with [`npx skills`](https://github.com/vercel-labs/skills). They work in Claude Code, Codex, OpenCode and GitHub Copilot.

## Skills

| Skill | What it does |
|---|---|
| [better-code-review](better-code-review/README.md) | A review that works like an investigation, for a finished branch, one or more pull or merge requests, or every change of a ticket across repositories. It lists what the change is required to do, maps what it affects beyond its own diff, sends targeted probes where that map shows risk, and reports a serious finding only after an independent challenger failed to disprove it. |

Install one with `-s <name>`:

```sh
npx skills add marekkawalski/skillbox-coding -g -s better-code-review
```

### Claude Code plugin marketplace

The repo is also a Claude Code marketplace; each skill is a plugin of the same name:

```
/plugin marketplace add marekkawalski/skillbox-coding
/plugin install better-code-review@skillbox-coding
```
