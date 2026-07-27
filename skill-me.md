# Skill me!

### The machine can't lift the bar for you. It can do every other thing a great coach does — but only if you ask.

![A hugely muscular man, drenched and grinning, mid-deadlift with a heavily loaded bar. Beside him a tripod projector shows a friendly robot face labelled AI Personal Trainer 3000, captioned "optimizing physique (positive reinforcement)". On the wall behind, a poster reads SMART & JOYFUL RECOVERY PROTOCOL: sleep, health, water, stretching, meditation, clean food.](IMG_4242.png)

---

## The prompt is the tell

Here are a few lines from a prompt I wrote recently, asking a model to produce a tutorial on Apple's Foundation Models framework:

> Version posture: write against the shipping 26 SDKs. Put every WWDC26 addition in a clearly-marked beta section near the end. Research the current APIs on the web first — do not write from memory — and cite Apple docs and WWDC sessions inline.

And from the list of things it had to cover:

> `@Generable` and constrained decoding; `@Guide` hard vs soft constraints; `PartiallyGenerated`; context windows and transcript condensation; the `GenerationError` catalogue; guardrails and prompt injection.

Look at what that actually is. It isn't a question. It's a **specification**, and every clause in it is a judgment call made by someone who already knew the terrain.

I knew the framework's public surface had shifted between releases, so I knew to fix a version posture and quarantine the beta material rather than let the two blur together. I knew that models happily invent plausible-looking Swift APIs, so I told it not to write from memory and to cite as it went. I knew which concepts a Swift developer meeting an LLM API for the first time would trip over, so I could name them and demand each one be introduced properly instead of dropped in mid-paragraph.

The result was genuinely good. But the quality was settled before the model produced a single token. It was settled by what I already knew.

That's the whole argument of this piece, in miniature.

---

## The flywheel

There is a loop here, and it runs in both directions.

The more you know about a domain, the more precisely you can specify what you want. The more precisely you specify, the better the output. The better the output, the more you learn from it — and the more of the work you can safely hand over next time. Which makes you more capable. Which makes your next specification sharper.

Capability doesn't just *let* you use the tool. It **compounds through** the tool.

This is why two people can put the same model in front of the same problem and get results that differ by an order of magnitude. The model is a constant. The person is the variable. What you bring determines what you can ask for, and — more importantly — what you can recognize when it comes back.

Because there's a second half to expertise that gets discussed far less than prompting: **evaluation**. Knowing that the framework doesn't work the way the model just said it does. Noticing that the argument has a hole in the third paragraph. Spotting the number that's off by a factor of ten. Delegation without the ability to evaluate isn't delegation. It's hope.

---

## To be clear: this is not an argument against agents

I'm not making the case for doing things the hard way out of principle, and I'm certainly not arguing against agentic use.

The opposite, in fact. The most aggressive delegation belongs to the person best equipped to write the spec and audit the result. A senior engineer can turn an agent loose on a large refactor precisely because they can read the diff and smell what's wrong. A junior can run the same agent and ship the same diff, and only one of them knows what just happened.

Same tool. Same tokens. Wildly different value, and the difference sits entirely on the human side.

Push it as far as you can. The point is that *how far you can push it* is a function of you — which makes the question of what happens to you the most commercially interesting question in the room.

---

## The same flywheel, running backwards

Multipliers are indifferent. They act on whatever you bring them, including less.

If capability compounds through the tool, then so does its absence. Skills you don't exercise decay — this isn't controversial, it's the most boring finding in all of human performance. Use it or lose it, in the gym and in the head.

What makes the AI case different is not the decay. It's the **invisibility** of the decay.

Normally, atrophy announces itself. Your writing gets flabby and an editor tells you. Your code gets worse and the reviews get longer. Your mental arithmetic goes and you catch yourself reaching for the phone. There's a signal, and the signal prompts a correction.

Now imagine that as your ability declines, something quietly steps in and takes up exactly the slack you dropped — so the output holds steady, or even improves. Your throughput goes up. Your deliverables look sharper than ever. Every visible measure says you're getting better.

The gauge has been disconnected from the engine. You're reading a dial that no longer measures you.

This isn't speculation. In 1983 the psychologist Lisanne Bainbridge published *Ironies of Automation*, a paper that has only grown more relevant with age. Her central irony: automating the routine parts of a job removes exactly the practice the operator needs to handle the non-routine parts — while leaving the operator responsible for those non-routine parts. Take away the easy work and you don't make the hard work easier. You make it harder, and you demolish the training ground.

Aviation learned this expensively. In 1997 an American Airlines captain, Warren VanderBurgh, gave a lecture called *Children of the Magenta Line* — named for the course line the flight computer draws across the display. His worry wasn't the autopilot; automation has saved vastly more lives in aviation than it has cost. His worry was pilots who had become superb managers of the system and mediocre flyers of the aircraft, and who, when things went wrong, reached instinctively for *more* automation rather than dropping a level and flying. Twelve years later, over the Atlantic, Air France 447's sensors iced up, the autopilot handed a perfectly airworthy aircraft back to its crew, and the crew stalled it into the sea.

And in 2025, a Microsoft Research and Carnegie Mellon study of 319 knowledge workers found the pattern reproducing itself in offices. The more people trusted the AI, the less critical thinking they reported doing. The more confidence they had in their *own* skill, the more they did. Buried in it is the finding that should make everyone sit up: people tended to skip scrutiny of the output precisely when they *lacked the expertise to inspect and improve it*.

That is the loop closing on itself. The less you know, the less able you are to see that you should be checking. Incompetence is self-concealing, and it now has an accomplice that makes the work look fine.

---

## Three old stories

None of this is new. We have been running this experiment, in various forms, for two thousand years.

**The man who bought Homer.** Seneca's twenty-seventh letter describes a rich Roman, Calvisius Sabinus, who badly wanted to be thought learned but couldn't keep Achilles and Priam straight. So he bought the capability instead: eleven enslaved men at ruinous cost — one holding Homer by heart, one Hesiod, one for each of the nine lyric poets — stationed at his dining couch to feed him verses on cue. He was quite certain that whatever anyone in his household knew, he knew.

The moral horror of the arrangement is the first thing to say about it. The second is the question it leaves on all our desks: **when an intelligent servant does the thinking, does the master learn anything?** Those same households put educated slaves in front of their children as tutors, and the children learned. The difference was never the servant. It was whether anybody was doing the work.

Seneca's punchline lands close to home. When a hanger-on suggested Sabinus take up wrestling for his health and he protested that he was barely well enough, the reply came: think how many perfectly healthy slaves you own. No one, Seneca concludes, can borrow or buy a sound mind.

**The Spacers.** Asimov's Spacers had it perfect — fifty worlds, thousands of robots per person, centuries of life, no drudgery and no want — and they dwindled and died while crowded, robot-poor Earth went on to seed the galaxy. The part worth keeping is that from the inside it never looked like decline. It looked like the summit. Capability doesn't leave with a bang; it leaves comfortably.

**The Heinzelmännchen.** And then the counter-example, which is the one to aim at. The elves of Cologne came out at night and did the townsfolk's work — dough kneaded, timber planed, leather cut and stitched, all finished by morning. Until the tailor's wife, dying to see them, scattered peas on the stairs. They tumbled, they fled, and Cologne has done its own work ever since.

Here's the part that matters: the shoemaker was a shoemaker. The elves multiplied a craft he already had; they didn't stand in for one he lacked. He knew good stitching when he saw it, which is precisely why he could profit from theirs. When they left he lost his leverage, not his livelihood.

That's the target state. Not "I could do this myself if I had to," said hopefully. Actually could.

---

## Now look again at the trainer

Which brings us back to the picture at the top, and to the thing I think most people get wrong about it.

Yes: the AI Personal Trainer 3000 cannot lift the bar. There is no prompt that transfers the adaptation. Hypertrophy requires load on *your* fibres, soreness in *your* body, hours *you* spent under tension. Nobody is confused about this in a gym. You would not hire a trainer and then ask him to do your sets, because the sets **are** the product.

But now count everything else a good trainer does.

He assesses you honestly, including the parts you'd rather not hear. He finds the weak link — not the lift you like doing, the one that's capping everything else. He writes a program with a shape and a sequence, not a pile of exercises. He progresses the load week over week so you're always working slightly beyond comfort. He adjusts when you travel, get sick, or catch a deadline at work, without letting you quietly abandon the season. He tests you on a schedule. He tells you, out loud, when you hit the number. And when you don't show up on Tuesday, he texts you.

Exactly one item on that list has to be done by you. Every other one can be handed over — and it will be done at 5 a.m., infinitely patiently, for free, by something with no interest in selling you the protein powder.

Almost nobody asks for any of it.

Now look at the wall in that gym. The poster doesn't say NO PAIN NO GAIN. It says **SMART & JOYFUL RECOVERY PROTOCOL** — sleep, water, stretching, meditation, clean food. Nobody has taken a single kilo off the bar; the man is drenched and straining and the load is entirely his. What's changed is that everything *around* the strain has become intelligent and humane, and none of it is his problem anymore.

And there's a detail in that poster worth dwelling on, because it's the thing people find hardest to believe about training: **you don't grow during the set.** You grow afterwards. The set is only the stimulus. The adaptation happens in the hours and days that follow — in rest, food, sleep, and the timing of the next session. Which means the irreducibly-yours part of the process is also the shortest, and the long tail where the gains actually accrue is almost entirely schedulable by someone else.

Learning works the same way. Yours is the effort of the attempt — sitting there not knowing, and pushing anyway. The spacing of your review, the sequencing, the timing of the next test, the consolidation: that's the recovery protocol, and a machine will run it for you far better than you will ever run it for yourself.

Note, too, that the man in the picture is *enormous*. Whatever else is going on in that basement, the protocol is working.

So ask for it. *Skill me.*

---

## What "skill me" actually looks like

Six moves. Together they're a coaching relationship rather than a vending machine.

### 1. Make it find the weak link

You cannot self-diagnose reliably. Nobody can. Your blind spots are, by construction, the things you can't see, and your sense of your own level is calibrated against people who are roughly your level.

This is the one place a model is genuinely better than your own judgment about you, because it isn't invested in your self-image. Give it real artifacts — actual code you shipped, an actual document you sent, a transcript of you explaining something out loud — and ask for a ranked list of your weaknesses, most consequential first.

The failure mode here is flattery, so make flattery expensive. Don't ask "how did I do?" Ask what someone two levels above you would notice in the first thirty seconds. Ask what's capping your *next* level, not this one. Ask what it would write if it were reviewing you for a promotion it thought you weren't ready for. Ask it to name the single thing that, if fixed, makes the other four irrelevant.

Then sit with the answer instead of arguing with it. The item you most want to dispute is usually the one to work on.

### 2. Make it write a program, not a reading list

A reading list is what you get when you ask badly. Twelve links, three books, a course. It feels like progress and produces none, because consuming material is not training.

A program has four properties a list doesn't: a **goal you'd recognize on arrival**, a **sequence with dependencies** (this before that, and here's why), a **time budget that matches the life you actually have**, and **exercises** — things you do, not things you read.

So give it the constraints up front: four hours a week, this is my current level, here's what I already know, here's the deadline, here's what I can't change. Ask it to justify the ordering, because the ordering is where the expertise lives and a bad one wastes months.

And write as much of the specification yourself as you can. If you can't say what "good" looks like at the end, that's your first request, not a detail to skip — because a person who can't define the target will accept whatever comes back.

### 3. Milestones with something to hand in

Every checkpoint needs an artifact. Not "understand streaming by Friday" — *by Friday, a working demo that streams partial results into a SwiftUI view and handles cancellation.* Something that either exists or doesn't.

This is where the load actually gets applied, so protect it. **Attempt first, check second.** Have the model set the exercise, then do it before you look at anything it has to say. The gap between your attempt and its critique is the entire lesson; read the good answer first and you'll get the warm feeling of understanding without any of the adaptation. Fluency isn't competence, and "yes, obviously" is the least reliable signal in adult learning.

Keep some fraction of the work strictly manual — your own hands, no help — in whichever skills your judgment rests on. Not all of it; that's just refusing the tool. Not none of it; that's the magenta line.

### 4. It has to survive contact with your life

Rigid plans die in week two, and they die quietly: you miss a session, then two, then the plan becomes a source of guilt, then it's gone. No announcement.

A real coach reschedules; he doesn't cancel the season. So keep the plan somewhere the model can revise it, and when you miss a week, don't restart from the top and don't pretend it didn't happen. Say what actually occurred and ask it to re-plan from where you really are.

Separate the **goal** (fixed) from the **route** (entirely negotiable). And let it absorb the distractions rather than fight them: the production incident that ate your Wednesday is also, if the plan can bend toward it, the best debugging exercise you'll get all month. Ask it to fold the interruption into the program instead of scheduling around it.

### 5. Test, and mark the result

Most of us carry a bad reflex about being tested, installed at school and never uninstalled: a question feels like a challenge to your competence, and a wrong answer feels like a verdict on you.

It isn't. **A question you get asked is not an attack on your person or your capabilities.** It's a request for information and an opening for reflection. Nobody putting it to you is auditing your worth — and when the questioner is a machine, there is not even anyone in the room to be embarrassed in front of.

Which makes the test the opposite of an enemy. It's the cheapest instrument you have for finding out two quite different things: what you don't know, and — the more interesting one — what you *do* know and failed to use. That second category is invisible without testing. You will never find it by reading, because on the page, knowledge you can't retrieve under pressure looks exactly like knowledge you can. In the gym it's the same distinction: a heavy single doesn't only measure the strength you have, it teaches you to express it.

Being tested isn't just measurement — it's a large part of the mechanism. Retrieving something under pressure builds the skill in a way that re-reading it never does. So schedule real tests: be quizzed cold, explain the concept back and be graded on the explanation, get handed a problem you can't solve by pattern-matching the examples.

One test to run on yourself, permanently: **when did you last catch the model in a real mistake?** If you can't remember, there are exactly two explanations and only one of them is flattering. Track your error-detection rate, not your throughput. Throughput is the disconnected gauge.

And then actually mark the completion. Write it down. Say it out loud. Have the model tell you plainly that you hit the milestone. This sounds soft and isn't — a loop with no terminating signal never terminates, and work that's never declared finished dissolves into an infinite backlog you eventually walk away from. The screen in that gym labels its own encouragement *(positive reinforcement)*, which is absurd and also exactly right. The reward is a functional component, not a sentiment.

### 6. Let it chase you

The optional one, and the one most people leave on the table.

Set conditions in advance, while you're still motivated, and let the machine hold you to them when you aren't: *if I haven't shipped the week-three artifact by Friday, ask me what happened and give me the smallest version that still counts. If I miss twice running, don't hand me the same plan again — propose a smaller one I'll actually finish.*

This is what the human coach is really for. Not the knowledge — that's been free for twenty years. The knowledge was never the bottleneck. Turning up was the bottleneck.

---

## The prompt, again

The piece opened with a specification. It should close with one — a different kind. Here's the shape:

> You are my coach for [skill], not my ghostwriter. Never produce the deliverable for me; if I ask you to, refuse and give me a hint instead.
>
> Attached are three samples of my real work. **First**, rank my five weakest areas, most consequential first, and be blunt — tell me what someone two levels above me would notice immediately. **Then** build a six-week program, four hours a week, where each week produces one artifact I can point at. Justify the sequence. **Each week**, give me the exercise and let me attempt it before you comment on anything. **At weeks three and six**, test me with something I can't complete by copying the examples. **If I miss a milestone**, don't rewrite the plan from scratch — re-plan from where I actually am and tell me the smallest step that gets me back on it. **When I hit a milestone, say so.**

Note the first line, because it's the one doing the real work: *never produce the deliverable for me; if I ask you to, refuse.*

You are building the refusal into the contract while you're still clear-headed, because at 11 p.m. on the night the thing is due, you will not be. That single instruction is the difference between the elves and the shoemaker.

---

## Read the poster again

![The same man, now visibly transformed, deadlifting a heavier bar and grinning, while the wall poster now reads SMART & JOYFUL RECOVERY PROTOCOL — sleep, water, meditation, health, stretching, clean food](IMG_4242.png)

Same basement. Same man. Heavier bar — and he is still sweating. Every one of those reps was his. The trainer never once touched the weight.

But look at the wall.

**NO PAIN NO GAIN** is gone. In its place: sleep, water, clean food, stretching, meditation. A recovery protocol.

Because that first poster was a half-truth, and the missing half is where most people fail. Nobody grows during the set. The set is only the *signal*; the growth happens afterwards — in the sleep, the food, the days you didn't train. You cannot skip the stimulus, which is the entire argument of this piece. But as a complete philosophy of training, "no pain, no gain" is how people get injured, plateau, and quit. Pain is necessary. It was never sufficient.

That's the whole difference between a slogan and a coach. A slogan names the one thing you must do. A coach names the one thing you must do *and* organizes the fourteen things around it that decide whether it pays off.

Which is exactly the offer on the table. The reps stay yours — permanently, non-negotiably. But the diagnosis, the programming, the progression, the sequencing, the recovery, the honest assessment, the test at week six, the nudge on Friday when you've gone quiet: all of that is available, all of it is what actually converts effort into capability, and almost none of it is being asked for.

The screen in the picture reads *positive reinforcement*. That's step five made visible — something reliably telling you that you hit the number, so the loop closes and the work counts as done.

With one condition, worth stating plainly: reinforcement is only worth anything if the same voice will tell you when you missed. Praise from something that only ever praises isn't information, it's a mirror — and a mirror is how you end up like Sabinus, surrounded by expertise and holding none of it. That's why the refusal clause goes in the contract on day one. The willingness to say *no, do it again* is precisely what makes the encouragement mean something.

---

## The multiplier is indifferent

The optimistic version of this essay is completely true. The better you get, the more this technology gives you, and what it gives you can make you better still. That flywheel is real, it's available today, and it's the best reason anyone has been given in a long time to become excellent at something.

But a multiplier doesn't care about the sign of what it's multiplying. Feed it a growing number and you get compounding growth. Feed it a shrinking one and you get compounding decline, delivered with a thumbs-up and a progress bar that reads *optimizing*.

The good news is that the same machine that can quietly take up your slack can just as easily be pointed at building you up instead — and it is far better at coaching than most of us have bothered to discover, because we keep asking it to do the sets.

Don't ask it to do the sets. Ask it to change the poster on the wall — and then do the sets.

*Skill me.*

---

### Sources and further reading

- Lisanne Bainbridge, "Ironies of Automation," *Automatica*, 1983 — [overview](https://en.wikipedia.org/wiki/Ironies_of_Automation)
- Lee et al., "The Impact of Generative AI on Critical Thinking," CHI 2025 — [paper (PDF)](https://www.microsoft.com/en-us/research/wp-content/uploads/2025/01/lee_2025_ai_critical_thinking_survey.pdf)
- Warren VanderBurgh, "Children of the Magenta Line," American Airlines, 1997 — [discussion](https://carlhendrick.substack.com/p/children-of-the-magenta-line)
- Seneca, *Moral Letters to Lucilius*, Letter 27 — [full text](https://en.wikisource.org/wiki/Moral_letters_to_Lucilius/Letter_27)
- Isaac Asimov, *The Naked Sun*, *Robots and Empire*, *Foundation and Earth*
- August Kopisch, "Die Heinzelmännchen zu Köln," 1836
