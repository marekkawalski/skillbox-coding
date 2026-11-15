# skillbox-coding

A box of hand-picked skills for your coding agent. Each one does a single job well; take out only the ones you need.

Install with [`npx skills`](https://github.com/vercel-labs/skills). They work in Claude Code, Codex, OpenCode and GitHub Copilot.

## Skills

| Skill | What it does |
|---|---|
| [better-code-review](better-code-review/README.md) | A review that works like an investigation, for a finished branch, one or more pull or merge requests, or every change of a ticket across repositories. It lists what the change is required to do, maps what it affects beyond its own diff, sends targeted probes where that map shows risk, and reports a serious finding only after an independent challenger failed to disprove it. |
| [better-grilling](better-grilling/SKILL.md) | Stress-tests a plan or design by interviewing you one question at a time. Every question comes in the same icon-marked card: why it matters, the concepts explained in plain words, a diagram where it helps, 2-4 options and a recommendation. It ends with a summary of decisions, assumptions and open points. Inspired by Matt Pocock's [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md), but asks one question at a time and explains every term, so you can answer without looking anything up. |

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
