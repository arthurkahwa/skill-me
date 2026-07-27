# skill-me

---

An [Agent Skill](https://agentskills.io/specification) that turns an AI agent into a coach instead of a ghostwriter. Works with any agent runtime that supports the Agent Skills spec — Claude, or otherwise.

![Positive Re-enforcement](assets/positive-reinforcement.png)

Most AI use is delegation: you ask for the thing, you get the thing. This skill inverts it. The agent assesses your actual work, writes you a real program, sets exercises, tests you, marks your milestones, and chases you when you skip — and refuses to produce the deliverable you're training to produce.

The trainer can spot you. The trainer cannot lift the bar.

> Companion piece: **Skill me!** — [Medium](https://medium.com/@arthur.kahwa/skill-me-69944061337a)

## What it does

Six moves, run as a coaching relationship rather than a vending machine:

1. **Find the weak link** — ranked diagnosis from real artifacts, structurally defended against flattery
2. **Write a program, not a reading list** — observable goal, dependency-ordered sequence, exercises you *do*
3. **Milestones with something to hand in** — every checkpoint produces an artifact that either exists or doesn't
4. **Survive contact with your life** — re-plans from where you actually are instead of dying quietly in week two
5. **Test, and mark the result** — including the failure mode nothing else catches: what you know and don't use
6. **Chase you** — conditions set while you're motivated, enforced when you aren't

## Install

Any runtime that loads Agent Skills (`SKILL.md` + frontmatter) can use this directly. A couple of concrete examples:

**Claude.ai / Claude Desktop** — download `skill-me.skill` from [Github](https://github.com/arthurkahwa/skill-me.git), then Settings → Capabilities → Skills → Upload.

**Claude Code**

```bash
git clone https://github.com:arthurkahwa/skill-me.git ~/.claude/skills/skill-me
```

Restart Claude Code. Confirm with `/skills`.

**Other agents / raw API** — point your skill loader at this directory, or paste `SKILL.md` into the system prompt.

## Use it

Just say what you want to get better at:

- "I want to get properly good at SQL — I keep asking the AI for queries and I still can't write a window function"
- "Coach me toward giving a conference talk in March"
- "Assess my writing and build me a six-week program, four hours a week"
- "Test me on last week's material, cold"

The agent will ask for real artifacts and an honest time budget before planning anything. Give it real work — prepared samples show what you can do with unlimited time and no pressure, which is rarely the problem.

## Some rules

```
Never produce the deliverable for me. If I ask you to, refuse and give me a hint instead.
Verify the examples for correct functioning before you write it. Make sure it can be used as-is without creating errors.
```

Set while you're clear-headed, because at 11 p.m. on the night the thing is due you will not be.

The skill protects only the target skill. Learning Rust but need a shell command to run your tests? It'll just tell you. The protected surface is narrow and specific: whatever you're training to do unaided.

## Structure

```
skill-me/
├── SKILL.md                        the protocol
├── references/
│   ├── assessment.md               ranked diagnosis, defeating flattery
│   ├── programming.md              observable goals, dependency ordering, load progression
│   ├── testing.md                  test types, marking completion, the error-detection check
│   └── refusal.md                  escalating hints, and when to make an exception
└── assets/
    ├── program-template.md         the plan, revised in place
    └── progress-log-template.md    the log, appended every session
```

Both templates are meant to live in your working directory. Coaching only works across sessions — a coach who doesn't remember last week isn't a coach.

## Examples

- [Apple Foundation models tutorial prompt](foundation_models_tutorial_prompt.md)
- [Apple Foundation models tutorial](foundation_models_tutorial.md)
- [Foundation Model Examples](./foundation_models_examples)

## Contributing

Issues and PRs welcome, particularly domain-specific assessment rubrics — the artifact table in `references/assessment.md` currently covers programming, writing, speaking, management, language, and design, and could use more.

## Licence

MIT — see [LICENSE](LICENSE).
