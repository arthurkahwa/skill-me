# Programming: from goal to plan

## The goal must be observable

Rewrite every stated goal into something with a pass/fail condition. This is not pedantry — an unobservable goal can never be marked complete, and an unmarkable program never ends.

| Stated | Rewritten |
|---|---|
| "Get better at writing" | "Publish a 2,000-word technical post that a senior engineer finishes" |
| "Learn Rust" | "Ship a CLI tool with tests that compiles clean under `-D warnings`" |
| "Improve my Spanish" | "Hold a 20-minute unscripted conversation without switching to English" |
| "Be a better manager" | "Run a performance conversation the other person calls useful" |
| "Understand transformers" | "Implement attention from scratch and explain each tensor shape without notes" |

If the learner can't tell you what "good" looks like, building that definition is week one.

## Sequence by dependency, not by syllabus

Textbook order optimises for exposition. Training order optimises for capability. They differ.

Ask: what is the smallest thing they could build or do that is *real*, and what does it require? Then order backwards from there. Skip anything the first real artifact doesn't need — it can come later, when there's a reason for it.

State the reason for the ordering in the plan. If you can't justify why week 3 precedes week 4, the sequence is arbitrary and probably wrong.

## Exercises, not resources

Every week needs something the learner *does*. A useful exercise has:

- a **deliverable** that either exists or doesn't
- a **difficulty just past current ability** — comfortable means no adaptation
- a **failure mode they'll actually hit**, not a sanitised toy problem
- a **time box**, so a stuck learner escalates instead of silently quitting

Resources support exercises; they don't replace them. Attach reading to the exercise that needs it, not to the week in general.

## Progressive load

Each week should be slightly harder than the last along one dimension: size, complexity, ambiguity, time pressure, or removal of scaffolding. Removing scaffolding is the most underused and often the most valuable — same task, but this time without the documentation open, without the template, without a starting skeleton.

If they clear three milestones without struggling, the program is too easy. Raise it and say why.

## Structure of the plan

Use `assets/program-template.md`. Keep the whole plan visible in one file — a learner who can see the arc understands why this week matters. Revise the file in place; never issue a competing plan in chat.

## Budget honesty

Multiply their stated available hours by 0.7 before planning. Everyone overestimates. A program that fits comfortably gets completed; a program that fits exactly gets abandoned in week three, and the abandonment is usually read by the learner as a personal failure rather than a planning error.
