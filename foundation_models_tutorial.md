# Apple Foundation Models: The Complete Guide

> A practical, example-driven tutorial on the **Foundation Models framework** — Apple's Swift API for the on-device large language model behind Apple Intelligence. Written against the **26 SDKs (iOS/iPadOS/macOS/visionOS 26, Xcode 26, Swift 6.2)**, which are the shipping, stable baseline.
>
> **Every code block in this guide compiles.** All examples were verified against the shipping `FoundationModels` module (Xcode 26, macOS 26 SDK) via a companion Swift package — no invented APIs, no pseudo-code.
>
> **How to read this.** Every code block is preceded by *what* it does and *why*, and nothing appears by magic — the first time an API shows up, it's named and explained. Part 1–3 is the whole framework as most apps use it, and §13 is a complete, runnable SwiftUI feature you can lift wholesale. Part 4 is what separates a demo from something you can ship. Where a claim is version-specific, it says so.
>
> **Companion reading:** if you've been through Paul Hudson's [*Swift Concurrency by Example*](https://www.hackingwithswift.com/quick-start/concurrency) and the `swift6_sendable_tutorial.md` in this folder, you already have the async/await and actor-isolation vocabulary this guide leans on — every API here is `async`, and almost all of it is `@MainActor`-adjacent because it drives UI.

## Table of contents

**Part 0 — Orientation**
1. [What this framework is, and what it isn't](#1-what-this-framework-is-and-what-it-isnt)
2. [The model: 3 billion parameters, and what that buys you](#2-the-model-3-billion-parameters-and-what-that-buys-you)
3. [Availability: check before you build UI on it](#3-availability-check-before-you-build-ui-on-it)

**Part 1 — The core loop**
4. [`LanguageModelSession`: instructions, prompts, responses](#4-languagemodelsession-instructions-prompts-responses)
5. [Prompting: builders, instructions vs prompts, and the rules that matter](#5-prompting-builders-instructions-vs-prompts-and-the-rules-that-matter)
6. [Streaming into SwiftUI](#6-streaming-into-swiftui)
7. [`GenerationOptions`: temperature, sampling, token budget](#7-generationoptions-temperature-sampling-token-budget)

**Part 2 — Structured output (the reason to use this framework)**
8. [`@Generable`: guided generation and constrained decoding](#8-generable-guided-generation-and-constrained-decoding)
9. [`@Guide`: constraining individual fields](#9-guide-constraining-individual-fields)
10. [`PartiallyGenerated`: streaming a structure, not tokens](#10-partiallygenerated-streaming-a-structure-not-tokens)
11. [Dynamic schemas: structure decided at runtime](#11-dynamic-schemas-structure-decided-at-runtime)

**Part 3 — Giving the model reach**
12. [Tool calling](#12-tool-calling)
13. [Capstone — a complete on-device feature in SwiftUI](#13-capstone--a-complete-on-device-feature-in-swiftui)

**Part 4 — Shipping it**
14. [Context windows, transcripts, and the errors you'll actually see](#14-context-windows-transcripts-and-the-errors-youll-actually-see)
15. [Safety: guardrails, instructions, and prompt injection](#15-safety-guardrails-instructions-and-prompt-injection)
16. [Performance: prewarming, token budgets, and Instruments](#16-performance-prewarming-token-budgets-and-instruments)
17. [Specialized use cases and custom LoRA adapters](#17-specialized-use-cases-and-custom-lora-adapters)
18. [Iterating and testing: Xcode Playgrounds, unit tests, feedback](#18-iterating-and-testing-xcode-playgrounds-unit-tests-feedback)

**Part 5 — Reference**
19. [Common mistakes and misconceptions](#19-common-mistakes-and-misconceptions)
20. [Quick reference](#20-quick-reference)

---

## 1. What this framework is, and what it isn't

**FoundationModels** is a Swift framework that hands you a large language model running **on the device**, with no API key, no network call, no per-token bill, and no data leaving the phone. Three lines get you a response:

```swift
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "Suggest a name for a coffee shop on a pier.")
print(response.content)   // "The Salted Bean"
```

That's the entire "hello world." What makes the framework interesting is not that line — every LLM SDK has that line — it's the four things Apple built *around* it:

| Capability | What it means | Section |
|---|---|---|
| **Guided generation** | The model's output is decoded *directly into your Swift type*. Not JSON you parse and hope for — a `struct` the compiler knows about, guaranteed structurally valid. | §8 |
| **Streaming snapshots** | You stream *partially built values of your type*, not raw tokens, so SwiftUI can render a half-finished structure. | §10 |
| **Tool calling** | The model can call your Swift functions mid-response — fetch data, hit a database, query the user's own content — and continue with the result. | §12 |
| **On-device, free, private** | Runs offline. Costs nothing. Never uploads a prompt. Usable on data you'd never send to a server. | §1 |

The framework is available on **iOS, iPadOS, macOS, and visionOS** (26 and later).

### What it isn't

Being honest about the ceiling saves you from building the wrong feature:

- **It is not ChatGPT.** It's a ~3-billion-parameter model tuned for *device-scale* tasks. It has thin world knowledge, and it will confidently invent facts it doesn't have (§2).
- **It is not a chatbot API.** You *can* build a chat UI, but the shape the framework is designed for is a **feature**: a summarizer, a tagger, a suggestion generator, a natural-language filter over content the user already has.
- **It is not a replacement for Writing Tools / Genmoji / Image Playground.** Those are system features you adopt with a modifier or an intent. This is the raw model for things Apple didn't build for you.
- **It is not Core ML.** Core ML runs *your* model. This runs *Apple's* model, the same one Apple Intelligence uses.

### The one-sentence version

**Use Foundation Models when the feature is "understand or generate text about the user's own content, on device, for free" — and use guided generation so the result is a Swift value your app can actually use, not a paragraph you have to parse.**

## 2. The model: 3 billion parameters, and what that buys you

The on-device model is **~3 billion parameters, quantized to roughly 2 bits per weight**. Both numbers matter and neither is a criticism — they're what makes it possible to ship an LLM that runs in the memory budget of a phone that's also running your app.

**What it is genuinely good at:**

- **Summarization** — the single most reliable task. Long text in, short text out.
- **Extraction and classification** — pull the date, the amount, the sentiment, the topic out of unstructured text.
- **Tagging** — generate topical labels for a note, a photo caption, a bookmark.
- **Short-form composition and rewriting** — a title, a caption, a friendlier version of a sentence.
- **Multi-turn dialogue** over content you supply it.

**What it is bad at, and will not get good at by prompting harder:**

- **World knowledge.** Ask it who won a match, what a company's revenue was, or anything after its training cutoff, and it will produce a plausible, wrong answer. If you need facts, *give* it the facts — in the prompt, or via a tool (§12).
- **Math.** Do arithmetic in Swift. Every time. `Decimal` doesn't hallucinate.
- **Code generation.** Not what it's tuned for.
- **Long chains of reasoning.** Break a multi-step task into several short prompts rather than one clever one.

**The context window is small, and this constrains your design more than anything else.** The on-device session holds roughly **4,096 tokens** on iOS 26 (readable at runtime via `contextSize` — §14). That's *everything*: your instructions, the whole conversation transcript, tool call arguments and outputs, and the response being generated. A token is roughly ¾ of a word. So "summarize this 40-page PDF" is not a prompt you can write; "summarize this 800-word section, then summarize the summaries" is.

> **Design consequence.** The small window pushes you toward *one-shot, single-purpose* sessions rather than long-running conversations. A session per feature invocation — created, used, discarded — is idiomatic here in a way it isn't with a server LLM.

## 3. Availability: check before you build UI on it

The model is not present on every device. It requires an Apple Intelligence-capable device, in a supported region, with Apple Intelligence enabled, and with the model assets actually downloaded. Any of those can fail, and **your feature must degrade rather than break**.

```swift
import FoundationModels

// SystemLanguageModel.default is the shared on-device model.
switch SystemLanguageModel.default.availability {
case .available:
    // Safe to create sessions.
    break

case .unavailable(.deviceNotEligible):
    // Old hardware. This will never become available — hide the feature entirely.
    break

case .unavailable(.appleIntelligenceNotEnabled):
    // The user can fix this in Settings. Say so; don't just grey a button out.
    break

case .unavailable(.modelNotReady):
    // Assets are still downloading (or deferred for storage/battery reasons).
    // This is transient — offer the feature again later rather than removing it.
    break

case .unavailable(let other):
    // New reasons can appear in future OS versions; always have a default branch.
    print("Unavailable: \(other)")
}
```

The three unavailability reasons need **three different UI responses**, and conflating them is the most common polish bug in shipped Foundation Models features:

| Reason | Will it resolve itself? | What the UI should do |
|---|---|---|
| `.deviceNotEligible` | Never | Don't render the entry point at all |
| `.appleIntelligenceNotEnabled` | If the user acts | Explain, and point at Settings |
| `.modelNotReady` | Probably, soon | Keep the entry point, disabled, with "preparing…" |

There's a convenience for the simple case, and a language check you should also make:

```swift
import Foundation   // Locale

let model = SystemLanguageModel.default
if model.isAvailable { /* … */ }

// The model supports a specific set of languages. Check before promising anything —
// generating in an unsupported language throws (§14) rather than silently degrading.
guard model.supportedLanguages.contains(Locale.current.language) else {
    // Hide the feature, or show a "not available in your language yet" note.
    return
}
```

**In SwiftUI**, gate at the view level so availability is part of your view's state, not a runtime surprise:

```swift
import FoundationModels
import SwiftUI

struct SummaryButton: View {
    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            Button("Summarize", action: summarize)
        case .unavailable(.appleIntelligenceNotEnabled):
            Button("Summarize", action: summarize)
                .disabled(true)
                .help("Turn on Apple Intelligence in Settings to use this.")
        case .unavailable:
            EmptyView()          // nothing to promise
        }
    }
    func summarize() { /* … */ }
}
```

## 4. `LanguageModelSession`: instructions, prompts, responses

[`LanguageModelSession`](https://developer.apple.com/documentation/foundationmodels/languagemodelsession) is the object you talk to. It is **stateful**: it owns a *transcript* of everything said so far, and every call appends to it.

```swift
let session = LanguageModelSession(
    instructions: """
        You are a concise assistant inside a hiking app.
        Answer in one or two sentences. Never invent trail names.
        """
)

let first  = try await session.respond(to: "What should I pack for a rainy day hike?")
let second = try await session.respond(to: "What about in winter?")   // remembers the first
```

The second call works because the session carried the first exchange forward. That's the whole point of a session — and also the whole cost, because that transcript eats your context window (§14).

### The three nouns

- **Instructions** — the standing brief. Who the model is, what it should and shouldn't do, what format to answer in. Supplied once, at session creation, and given precedence over anything in a prompt. **Instructions come from you, the developer — never from the user** (§15).
- **Prompt** — one request. Usually a mix of your framing and the user's input.
- **Response** — what comes back: `response.content` (typed — `String` by default, or your `@Generable` type, §8), plus `response.transcriptEntries` and `response.rawContent` (the underlying `GeneratedContent`).

### Creating a session

```swift
// Simplest: default model, no instructions, no tools.
let bare = LanguageModelSession()

// The full shape you'll actually use:
let session = LanguageModelSession(
    model: SystemLanguageModel.default,          // which model (defaults to on-device)
    tools: [],                                   // functions the model may call — see §12
    instructions: "You help plan day hikes."     // the standing brief
)
```

### Inspecting and controlling a session

```swift
session.isResponding        // Bool — true while a response is in flight
session.transcript          // Transcript — the full ordered history
session.prewarm()           // load the model into memory ahead of the first real request (§16)
```

> **One request at a time.** A `LanguageModelSession` services a single request at a time. Calling `respond(to:)` again while `isResponding` is `true` throws. Disable your submit button on `isResponding` — that's the intended pattern, not a workaround. If you genuinely need concurrency, create *separate sessions*; they're cheap, and they don't share a transcript.

### Sessions are per-feature, not per-app

Because the transcript is the context budget, a long-lived app-wide session is usually the wrong architecture. Prefer:

- **One session per feature invocation** for one-shot work (summarize *this* note) — create, use, drop.
- **One session per conversation** for actual dialogue, with a plan for what happens when it overflows (§14).

A reasonable owner for one is an `@Observable` model class, `@MainActor`-isolated because it drives UI:

```swift
import FoundationModels
import Observation   // @Observable lives here — SwiftUI re-exports it, but this file doesn't import SwiftUI

@Observable
@MainActor
final class SummarizerModel {
    private let session = LanguageModelSession(
        instructions: "Summarize notes in at most three sentences. Keep the author's tone."
    )

    private(set) var summary: String = ""
    var isBusy: Bool { session.isResponding }

    func summarize(_ note: String) async throws {
        summary = try await session.respond(to: "Summarize this note:\n\n\(note)").content
    }
}
```

## 5. Prompting: builders, instructions vs prompts, and the rules that matter

### The prompt builder

Both instructions and prompts accept a **result builder**, so you can assemble them from conditionals and loops instead of doing string surgery:

```swift
// Stand-ins for whatever your app already knows about the user and their request.
struct UserPreferences {
    let prefersMetric: Bool
    let allergy: String?
}
let user = UserPreferences(prefersMetric: true, allergy: "peanuts")
let ingredients = ["eggs", "spinach", "feta"]

let session = LanguageModelSession {
    "You are a helpful assistant inside a recipe app."
    "Answer in plain sentences, no markdown."

    if user.prefersMetric {
        "Always use metric units."
    }
}

let response = try await session.respond {
    "Suggest a dinner using only these ingredients:"
    ingredients.joined(separator: ", ")

    if let allergy = user.allergy {
        "DO NOT suggest anything containing \(allergy)."
    }
}
```

This is `@InstructionsBuilder` and `@PromptBuilder` — the same mechanism as `@ViewBuilder`. Each string becomes a line. Use it whenever a prompt varies by state; it's far easier to read than interpolated multi-line strings, and much easier to diff when you're iterating on wording.

### Instructions vs prompts — the distinction that carries the safety model

| | Instructions | Prompt |
|---|---|---|
| Supplied | Once, at session creation | Per request |
| Authored by | **You** | You + **the user** |
| Precedence | Higher — the model is trained to prefer them | Lower |
| Safe to contain user text? | **Never** | Yes, that's the point |

The reason this matters isn't stylistic. Instructions are the mechanism the model uses to resist being talked out of its job. Put user text into instructions and you've handed the user the steering wheel — a prompt injection with no defense left (§15).

### Prompting a 3B model: what actually works

Techniques that pay off on a small on-device model, roughly in order of impact:

**1. Say how long.** The model is bad at guessing. Tell it.

```swift
"Summarize this in exactly three sentences."     // short
"Describe the route in detail."                  // long
```

**2. Give it a role and a voice.** One clause is enough.

```swift
"You are a terse, practical trail guide. No pleasantries."
```

**3. Show, don't explain.** A couple of examples beat a paragraph of description — but keep it under about five, because every example is context you're spending.

```swift
try await session.respond {
    "Rewrite each title in sentence case."
    "Example: 'THE BEST HIKES' -> 'The best hikes'"
    "Example: 'a walk in fog' -> 'A walk in fog'"
    "Now rewrite: \(title)"
}
```

**4. Commands, not requests.** "Generate three tags." beats "Could you please provide some tags?"

**5. Shout the negatives.** Small models drop negations. Apple's own guidance is to use caps for prohibitions:

```swift
"DO NOT include the author's name."
"DO NOT use emoji."
```

**6. Decompose.** Two focused prompts beat one clever one. Extract, *then* rank. Classify, *then* summarize. Each step is short, checkable, and cheap.

**7. Don't describe the output format.** If you want structure, don't ask for JSON in prose — use `@Generable` (§8). It's more reliable, it's faster, and it removes the parsing code entirely.

## 6. Streaming into SwiftUI

A full response takes seconds. Waiting on a spinner for it feels broken. Streaming turns that into visible progress:

```swift
import FoundationModels
import SwiftUI

@Observable
@MainActor
final class StoryModel {
    private let session = LanguageModelSession(instructions: "You write short bedtime stories.")
    private(set) var text: String = ""

    func write(about subject: String) async throws {
        // streamResponse returns a ResponseStream — an AsyncSequence of snapshots.
        let stream = session.streamResponse(to: "Write a bedtime story about \(subject).")

        for try await snapshot in stream {
            text = snapshot.content        // the whole story so far, not just the new bit
        }
    }
}
```

```swift
struct StoryView: View {
    @State private var model = StoryModel()

    var body: some View {
        ScrollView {
            Text(model.text)
                .animation(.easeOut, value: model.text)   // soften each arrival
        }
        .task { try? await model.write(about: "a fox who can't sleep") }
    }
}
```

Two facts about that loop that will save you a bug each:

> **Snapshots are cumulative, not deltas.** Each element is the *entire* content generated so far. Assign it (`text = snapshot.content`), never append it (`text += …`) — appending gives you exponentially duplicated text, and it's the single most common streaming mistake.

> **API shape note.** In the original iOS 26.0 SDK, `ResponseStream`'s element *was* the partial value itself, so older articles show `for try await partial in stream { text = partial }`. The shipping API wraps it in a snapshot carrying the content plus progress metadata — hence `snapshot.content`. If a sample doesn't compile, that's usually why.

If you also want the finished value after the loop, `collect()` gives it to you without re-running anything:

```swift
let stream = session.streamResponse(to: prompt)
for try await snapshot in stream { text = snapshot.content }
let final = try await stream.collect()          // the complete Response
```

Streaming really comes into its own with **structured** output, where each snapshot is a partially-filled version of your own type — that's §10.

## 7. `GenerationOptions`: temperature, sampling, token budget

`GenerationOptions` is a per-request knob set passed to `respond`/`streamResponse`:

```swift
let response = try await session.respond(
    to: prompt,
    options: GenerationOptions(temperature: 0.4, maximumResponseTokens: 300)
)
```

**Temperature** (0…2, default around 1) is the creativity dial:

| Temperature | Behavior | Use for |
|---|---|---|
| `0.0`–`0.5` | Focused, repetitive, predictable | Extraction, classification, tagging |
| `~1.0` | Balanced (default) | Summaries, general text |
| `1.5`–`2.0` | Wild, varied, occasionally incoherent | Brainstorming, creative variants |

**Sampling** picks *how* the next token is chosen:

```swift
GenerationOptions(sampling: .greedy)                       // always the top token — repeatable
GenerationOptions(sampling: .random(top: 40))              // top-k
GenerationOptions(sampling: .random(probabilityThreshold: 0.9))  // nucleus / top-p
```

> **`.greedy` is as close to deterministic as you get** — the same prompt gives the same output, *for a given model version*. It is not a guarantee across OS updates: Apple ships new model weights with OS releases, and output can change. Never snapshot-test exact model output (§18).

**`maximumResponseTokens`** caps output length. It's a hard stop, not a style hint — the response is *truncated*, not gracefully shortened. Use it as a safety belt against runaway generation, and ask for brevity in the prompt for the actual length control.

A useful default pairing, worth internalizing:

```swift
// Extraction / structured data: low temperature, tight budget.
GenerationOptions(temperature: 0.2, maximumResponseTokens: 200)

// User-facing prose: leave temperature alone, cap the runaway case.
GenerationOptions(maximumResponseTokens: 500)
```

## 8. `@Generable`: guided generation and constrained decoding

This is the feature that justifies the framework, and the one that has no real equivalent in a plain HTTP LLM API.

Annotate a Swift type with `@Generable` and the model will produce **that type** — not JSON-shaped text you parse, not a paragraph you regex. The macro reads your type at compile time and emits a **generation schema**; at inference time the framework uses that schema to *constrain decoding*, so tokens that would break the structure are never sampled in the first place.

```swift
import FoundationModels

@Generable
struct Recipe {
    let title: String
    let servings: Int
    let ingredients: [String]
    let steps: [String]
}

let session = LanguageModelSession(instructions: "You are a home-cooking assistant.")

let response = try await session.respond(
    to: "Invent a weeknight dinner using eggs, spinach and feta.",
    generating: Recipe.self
)

let recipe = response.content        // a Recipe. Not a String. Fully typed.
print(recipe.servings + 2)           // it's an Int, so this compiles
```

Three consequences, all of them load-bearing:

1. **Structural validity is guaranteed, not hoped for.** The model *cannot* emit a missing field or a string where an `Int` belongs, because those tokens are masked out during sampling. There is no `JSONDecoder`, no `try?`, no "sometimes the model wraps it in a markdown fence."
2. **It's faster.** A constrained model has fewer options per token, and the framework doesn't waste output tokens on syntax it can supply itself.
3. **It's more accurate.** Not having to spend attention on formatting leaves more for the actual task. Apple's guidance is explicit: with guided generation, *stop describing the format in your prompt*. Just say what you want; the schema handles shape.

### What can be `@Generable`

- **Primitives:** `String`, `Int`, `Double`, `Float`, `Bool`, `Decimal`
- **Arrays** of generable elements
- **Optionals** — the model may omit the value
- **Nested `@Generable` structs**, composed freely
- **Enums**, including **with associated values**:

```swift
@Generable
struct TaskItem {
    let title: String
    let urgency: Urgency
    let schedule: Schedule

    @Generable
    enum Urgency { case low, normal, urgent }

    @Generable
    enum Schedule {
        case whenever
        case onDay(String)
        case within(days: Int)
    }
}
```

Enums with associated values are how you let the model choose *between shapes* — a genuinely powerful trick for routing the model between different structured outcomes.

- **Recursive types**, for trees and outlines:

```swift
@Generable
struct OutlineNode {
    let heading: String
    let children: [OutlineNode]
}
```

> **Property order is semantic.** The model fills properties in **declaration order**, and each one is generated with the previous ones already in context. So put the fields that *inform* later fields first. `title` before `summary` gives a summary that matches the title; the reverse gives a title bolted onto an unrelated summary. This also controls the order things appear when streaming (§10) — which is a UI decision as much as a quality one.

## 9. `@Guide`: constraining individual fields

`@Generable` fixes the *shape*. `@Guide` fixes the *content* of each field — in natural language, or as a hard constraint the decoder enforces.

```swift
@Generable
struct TripPlan {
    @Guide(description: "A short, evocative name for the trip. No punctuation.")
    let title: String

    @Guide(.range(1...14))
    let days: Int

    @Guide(description: "One activity per day", .count(3))
    let activities: [String]

    @Guide(.anyOf(["budget", "moderate", "luxury"]))
    let tier: String

    @Guide(description: "Rough total in euros")
    let estimatedCost: Double
}
```

The guide vocabulary, by field type:

| Field type | Guides | Enforcement |
|---|---|---|
| Any | `description:` — natural language | Soft: steers the model |
| `Int`, `Double` | `.range(1...10)`, `.minimum(0)`, `.maximum(100)` | **Hard**: decoder-enforced |
| Arrays | `.count(3)`, `.count(3...8)`, `.minimumCount(1)`, `.maximumCount(5)` | **Hard** |
| `String` | `.anyOf([...])` | **Hard**: one of those exact strings |
| `String` | a `Regex` literal | **Hard**: output matches the pattern |

The distinction between **hard** and **soft** guides is the thing to remember: a `description` is a *suggestion the model usually follows*; a `.range` or `.count` is a *rule the decoder physically cannot break*. When correctness matters, express it as a constraint, not a sentence.

Regex guides are the sharpest tool in the set — you can pin a format exactly, using Swift's regex builder DSL:

```swift
import FoundationModels
import RegexBuilder   // Capture, ChoiceOf, OneOrMore — the regex builder DSL lives here

@Generable
struct Contact {
    @Guide(Regex {
        Capture { ChoiceOf { "Dr"; "Mr"; "Ms" } }
        ". "
        OneOrMore(.word)
    })
    let name: String        // e.g. "Dr. Brewster" — never anything else
}
```

> **Don't restate guides in the prompt.** If `days` is `.range(1...14)`, saying "between 1 and 14 days" in the prompt is wasted context — the constraint is already unbreakable. Spend those tokens on something the schema can't express.

## 10. `PartiallyGenerated`: streaming a structure, not tokens

Here's where guided generation and streaming combine into something you can't do with a plain text API.

The `@Generable` macro generates a companion type, `YourType.PartiallyGenerated`, which is a mirror of your struct with **every property optional**. Streaming a generable type yields a sequence of those partial values, progressively filled in — so your SwiftUI view can render the title the moment it exists, then the ingredients as they arrive, and so on.

```swift
import FoundationModels
import SwiftUI

@Observable
@MainActor
final class RecipeModel {
    private let session = LanguageModelSession(instructions: "You are a home-cooking assistant.")
    private(set) var partial: Recipe.PartiallyGenerated?

    func generate(from ingredients: String) async throws {
        let stream = session.streamResponse(
            to: "Invent a weeknight dinner using: \(ingredients)",
            generating: Recipe.self
        )
        for try await snapshot in stream {
            partial = snapshot.content       // Recipe.PartiallyGenerated
        }
    }
}
```

The view unwraps optimistically — each field appears as it lands:

```swift
struct RecipeView: View {
    let recipe: Recipe.PartiallyGenerated?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = recipe?.title {
                Text(title).font(.title2.bold())
                    .transition(.opacity)
            }
            if let servings = recipe?.servings {
                Text("Serves \(servings)").foregroundStyle(.secondary)
            }
            if let ingredients = recipe?.ingredients {
                ForEach(ingredients, id: \.self) { Text("• \($0)") }
            }
            if let steps = recipe?.steps {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    Text("\(i + 1). \(step)")
                }
            }
        }
        .animation(.smooth, value: recipe?.ingredients?.count)
    }
}
```

Notes worth having in your head before you write this the first time:

- **Arrays grow element by element**, and the *last* element can itself be half-generated. Design the row so a partially-written string looks fine (it usually does — it reads as typing).
- **Give rows a stable identity.** Partially generated values carry a framework-supplied `GenerationID`; use that (or a stable index) for `ForEach` identity, rather than the text content — otherwise every keystroke of generated text re-creates the row and your animations flicker.
- **Declaration order is presentation order** (§8). If you want the headline first on screen, declare it first in the struct. This is the rare case where a data-model decision *is* a UI decision.
- **Animate arrivals.** A `.transition(.opacity)` per field and a `.animation` on the collection count is the difference between "fast" and "janky," for exactly the same latency.

## 11. Dynamic schemas: structure decided at runtime

`@Generable` needs the type at compile time. Sometimes you don't have it — the structure comes from a server config, a user-designed form, a document template. `DynamicGenerationSchema` builds a schema at runtime and gets the same constrained decoding.

```swift
// Build a schema for a structure we only learn about at runtime.
var properties: [DynamicGenerationSchema.Property] = []

properties.append(.init(
    name: "question",
    schema: DynamicGenerationSchema(type: String.self)
))
properties.append(.init(
    name: "answers",
    schema: DynamicGenerationSchema(arrayOf: DynamicGenerationSchema(referenceTo: "Answer"))
))

let riddle = DynamicGenerationSchema(name: "Riddle", properties: properties)

let answer = DynamicGenerationSchema(name: "Answer", properties: [
    .init(name: "text",      schema: DynamicGenerationSchema(type: String.self)),
    .init(name: "isCorrect", schema: DynamicGenerationSchema(type: Bool.self))
])

// Dependencies are the other schemas referenced by name. Validated up front.
let schema = try GenerationSchema(root: riddle, dependencies: [answer])

let session = LanguageModelSession(instructions: "You write short riddles.")
let response = try await session.respond(to: "Generate a riddle about coffee", schema: schema)

// The result is GeneratedContent — dynamically typed, read by property name.
let question = try response.content.value(String.self, forProperty: "question")
let answers  = try response.content.value([GeneratedContent].self, forProperty: "answers")
```

You trade compile-time typing for runtime flexibility, and you get `GeneratedContent` — a dynamically-keyed value you read with `value(_:forProperty:)`. Everything else (constrained decoding, guarantees, streaming) works identically.

Reach for this **only** when the shape genuinely isn't known at build time. `@Generable` is better in every other respect: type safety, autocompletion, refactoring, and no stringly-typed property lookups.

## 12. Tool calling

A tool is **a Swift function the model is allowed to call, mid-response, when it decides it needs to**. This is how you fix the model's two big gaps — no world knowledge, no access to the user's data — without stuffing everything into the prompt "just in case."

The `Tool` protocol has four parts: a name, a description, a `@Generable` `Arguments` type, and a `call` function.

```swift
import FoundationModels
import WeatherKit
import CoreLocation

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Get the current weather for a named city."

    // The model generates these arguments — @Generable means they're always valid.
    @Generable
    struct Arguments {
        @Guide(description: "A city name, e.g. 'Munich'")
        let city: String
    }

    // A small lookup keeps the example on the Tool protocol, not geocoding.
    private static let coordinates: [String: CLLocationCoordinate2D] = [
        "munich": .init(latitude: 48.1374, longitude: 11.5755),
        "berlin": .init(latitude: 52.5200, longitude: 13.4050),
        "kiel":   .init(latitude: 54.3233, longitude: 10.1228),
    ]

    // Whatever you return is fed back into the model's context and it keeps going.
    func call(arguments: Arguments) async throws -> String {
        // Always return something the model can use, even on a miss (see below).
        guard let coordinate = Self.coordinates[arguments.city.lowercased()] else {
            return "No weather data for \(arguments.city)."
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await WeatherService.shared.weather(for: location)
        return "\(arguments.city): \(weather.currentWeather.temperature.formatted()), " +
               "\(weather.currentWeather.condition.description)"
    }
}
```

Register it on the session, and then *don't think about it again* — you never call the tool yourself:

```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "You help people plan their day. Use tools to get real information."
)

let response = try await session.respond(to: "Should I cycle to work in Munich today?")
// Behind the scenes: model decides it needs weather → generates {city: "Munich"} →
// framework calls your function → output goes into the transcript → model answers.
```

### The lifecycle, precisely

1. The model reads the prompt and decides whether a tool is needed (based on your `name` and `description` — those are prompt text, so write them well).
2. It generates the `Arguments` value, using constrained decoding against your `@Generable` schema. Invalid arguments are structurally impossible.
3. The framework calls `call(arguments:)`.
4. The return value is appended to the transcript as tool output.
5. The model continues generating, now with that information in context.

The model can call **several tools in parallel** for one request, and can call the same tool **multiple times**. It can also decide not to call anything.

### Return types

The `Output` of a tool is any `PromptRepresentable` value. In practice that means:

```swift
func call(arguments: Arguments) async throws -> String            // simplest, usually enough
func call(arguments: Arguments) async throws -> GeneratedContent  // structured output
```

`GeneratedContent(properties:)` is the structured form, useful when the result has several fields the model should be able to distinguish. (WWDC25-era material shows a `ToolOutput` wrapper type; the shipping API generalized it to an associated `Output` type — if you're following an older sample, that's the difference.)

### Stateful tools

Tools are objects, so they can hold state across calls — for deduplication, caching, or feeding results back to your app. Because `Tool` is `Sendable` and `call` may run off the main actor, keep any mutable state in an `actor` rather than a plain `var` — a `final class` with a mutable stored property will not compile under Swift 6:

```swift
struct Photo: Sendable, Identifiable {
    let id: String
    let caption: String
}

struct PhotoLibrary: Sendable {
    func search(_ description: String) async throws -> [Photo] { /* … */ [] }
}

// Mutable dedup state lives in an actor, so the tool itself stays Sendable.
actor ReturnedPhotos {
    private var ids: Set<String> = []
    func pick(from candidates: [Photo]) -> Photo? {
        guard let photo = candidates.first(where: { !ids.contains($0.id) }) else { return nil }
        ids.insert(photo.id)
        return photo
    }
}

final class FindPhotoTool: Tool {
    let name = "findPhoto"
    let description = "Find a photo in the user's library matching a description."

    private let returned = ReturnedPhotos()
    let library: PhotoLibrary

    init(library: PhotoLibrary) { self.library = library }

    @Generable struct Arguments { let description: String }

    func call(arguments: Arguments) async throws -> String {
        let candidates = try await library.search(arguments.description)
        guard let pick = await returned.pick(from: candidates) else {
            return "No matching photo found."
        }
        return pick.caption
    }
}
```

### Writing tools the model actually uses well

- **Short names, verb-first:** `getWeather`, `findContact`, `searchNotes`. Not `WeatherRetrievalService`.
- **One-sentence descriptions.** They're spent from your context budget on every single request, whether the tool is called or not.
- **Few tools.** Three focused tools beat ten overlapping ones; overlap makes the model dither and pick wrong.
- **Always return something.** `"No matching photo found."` is far more useful to the model than a thrown error — it can explain the miss to the user. Throw only for genuine failures.
- **Keep them fast.** The model is blocked while your tool runs, and the user is watching.
- **Treat arguments as untrusted.** The model generated them, possibly under the influence of user text. Validate before you delete anything, spend anything, or send anything (§15).

## 13. Capstone — a complete on-device feature in SwiftUI

Everything so far, assembled into one runnable feature: **"Cook What I Have."** The user types what's in their fridge; the app streams back a structured recipe, using a tool that checks the user's pantry list for staples the model shouldn't have to be told about.

This is complete — availability gating, prewarming, streaming structured output, a tool, error handling, and a cancel path.

**1. The structured output.** Note the deliberate field order: `title` first (it appears first on screen and frames everything after it), and hard constraints where correctness matters.

```swift
import FoundationModels
import SwiftUI

@Generable
struct CookRecipe {
    @Guide(description: "An appetising name, 2-5 words, no punctuation")
    let title: String

    @Guide(description: "One sentence on why this works")
    let pitch: String

    @Guide(.range(1...8))
    let servings: Int

    @Guide(description: "Total active cooking time in minutes", .range(5...120))
    let minutes: Int

    @Guide(description: "Ingredient with quantity, e.g. '200g spinach'", .count(3...10))
    let ingredients: [String]

    @Guide(description: "One imperative step per entry", .count(3...8))
    let steps: [String]
}
```

**2. The tool.** It gives the model access to app data it has no other way to know.

```swift
struct PantryTool: Tool {
    let name = "checkPantry"
    let description = "Check whether a staple ingredient is already in the user's pantry."

    let pantry: Set<String>          // injected from the app's own store

    @Generable
    struct Arguments {
        @Guide(description: "A single ingredient name, singular, lowercase")
        let ingredient: String
    }

    func call(arguments: Arguments) async throws -> String {
        pantry.contains(arguments.ingredient.lowercased())
            ? "\(arguments.ingredient): in the pantry"
            : "\(arguments.ingredient): NOT in the pantry, must be bought"
    }
}
```

**3. The model object.** `@MainActor` because it drives UI; `@Observable` so SwiftUI tracks the partial value as it fills in.

```swift
@Observable
@MainActor
final class CookModel {
    enum State: Equatable {
        case idle
        case unavailable(String)      // human-readable reason
        case generating
        case failed(String)
        case done
    }

    private(set) var state: State = .idle
    private(set) var recipe: CookRecipe.PartiallyGenerated?

    private var session: LanguageModelSession?
    private var task: Task<Void, Never>?
    private let pantry: Set<String>

    init(pantry: Set<String>) {
        self.pantry = pantry

        // Gate on availability BEFORE building any session or UI affordance (§3).
        switch SystemLanguageModel.default.availability {
        case .available:
            session = makeSession()
            // Warm the model now, while the user is still typing, so the first
            // token arrives sooner when they hit the button (§16).
            session?.prewarm()
        case .unavailable(.deviceNotEligible):
            state = .unavailable("This device doesn't support on-device intelligence.")
        case .unavailable(.appleIntelligenceNotEnabled):
            state = .unavailable("Turn on Apple Intelligence in Settings to use this.")
        case .unavailable(.modelNotReady):
            state = .unavailable("Preparing the model — try again shortly.")
        case .unavailable:
            state = .unavailable("On-device intelligence isn't available right now.")
        }
    }

    private func makeSession() -> LanguageModelSession {
        LanguageModelSession(tools: [PantryTool(pantry: pantry)]) {
            "You are a practical weeknight cooking assistant."
            "Suggest one recipe using mostly the ingredients the user names."
            "Use the checkPantry tool for staples like salt, oil, flour or rice."
            "DO NOT suggest ingredients the user cannot plausibly have."
            "DO NOT include any commentary outside the recipe."
        }
    }

    func generate(from ingredients: String) {
        guard let session, !session.isResponding else { return }
        task?.cancel()
        recipe = nil
        state = .generating

        task = Task {
            do {
                let stream = session.streamResponse(
                    to: "Ingredients on hand: \(ingredients)",
                    generating: CookRecipe.self,
                    // Low temperature: we want a sensible recipe, not a surprising one.
                    options: GenerationOptions(temperature: 0.6, maximumResponseTokens: 600)
                )
                // `self.` is required: this is an escaping closure capturing a class.
                for try await snapshot in stream {
                    self.recipe = snapshot.content
                }
                self.state = .done
            } catch is CancellationError {
                self.state = .idle
            } catch LanguageModelSession.GenerationError.guardrailViolation {
                // Never show the raw error. Say something useful (§15).
                self.state = .failed("Let's try that with different ingredients.")
            } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                // The conversation outgrew the window — start fresh (§14).
                self.session = self.makeSession()
                self.state = .failed("That was a lot to take in. Try again?")
            } catch {
                self.state = .failed("Something went wrong generating that recipe.")
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
```

**4. The view.** Fields render the instant they exist; the button reflects `isResponding`.

```swift
struct CookView: View {
    @State private var model = CookModel(pantry: ["salt", "olive oil", "rice", "flour"])
    @State private var ingredients = ""

    var body: some View {
        Form {
            switch model.state {
            case .unavailable(let reason):
                ContentUnavailableView("Not available", systemImage: "sparkles.slash",
                                       description: Text(reason))
            default:
                Section {
                    TextField("What's in your fridge?", text: $ingredients, axis: .vertical)
                    Button(model.state == .generating ? "Generating…" : "Suggest a recipe") {
                        model.generate(from: ingredients)
                    }
                    .disabled(ingredients.isEmpty || model.state == .generating)
                }

                if let recipe = model.recipe {
                    Section {
                        if let title = recipe.title {
                            Text(title).font(.title3.bold())
                        }
                        if let pitch = recipe.pitch {
                            Text(pitch).foregroundStyle(.secondary)
                        }
                        if let servings = recipe.servings, let minutes = recipe.minutes {
                            Label("Serves \(servings) · \(minutes) min", systemImage: "clock")
                                .font(.caption)
                        }
                    }
                    if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                        Section("Ingredients") {
                            ForEach(ingredients, id: \.self) { Text($0) }
                        }
                    }
                    if let steps = recipe.steps, !steps.isEmpty {
                        Section("Method") {
                            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                                Text("\(i + 1). \(step)")
                            }
                        }
                    }
                }

                if case .failed(let message) = model.state {
                    Text(message).foregroundStyle(.red)
                }
            }
        }
        .animation(.smooth, value: model.recipe?.steps?.count)
        .onDisappear { model.cancel() }
    }
}
```

Walk the pieces against the earlier sections: availability gating (§3), a builder-composed instruction set (§5), a tool the model calls on its own (§12), a `@Generable` type with hard guides (§8–9), streamed partial values rendered progressively (§10), tuned generation options (§7), and typed error handling with a UI response for each case (§14–15). That's the whole framework, in about 150 lines.

## 14. Context windows, transcripts, and the errors you'll actually see

### The transcript is your budget

Every session carries a `Transcript` — an ordered list of entries: instructions, prompts, responses, tool calls, tool outputs. **All of it counts against the context window**, along with the response being generated.

```swift
// `Transcript` is itself a RandomAccessCollection of entries — iterate it directly.
for entry in session.transcript {
    // .instructions, .prompt, .response, .toolCalls, .toolOutput
    print(entry)
}
```

You can measure this directly instead of estimating. `contextSize` has been available since iOS 26.0; `tokenCount(for:)` arrived in iOS 26.4, so guard it if your deployment target is still 26.0–26.3:

```swift
let model = SystemLanguageModel.default
model.contextSize                          // 4096 on iOS 26

if #available(iOS 26.4, macOS 26.4, visionOS 26.4, *) {
    let used = try await model.tokenCount(for: session.transcript)
    print("Used \(used) of \(model.contextSize) tokens")
}
```

### Recovering from an overflow

Overflow isn't an edge case in a multi-turn feature — it's the *expected* end state. Handle it by starting a new session seeded with a condensed transcript:

```swift
do {
    let answer = try await session.respond(to: prompt)
    // …
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    session = condensed(from: session)
    // optionally retry the prompt against the new session
}

private func condensed(from old: LanguageModelSession) -> LanguageModelSession {
    let entries = Array(old.transcript)
    var kept: [Transcript.Entry] = []

    // ALWAYS keep the first entry — that's your instructions. Losing them
    // loses the model's entire brief, and quality falls off a cliff.
    if let first = entries.first { kept.append(first) }
    if let last = entries.last, entries.count > 1 { kept.append(last) }

    return LanguageModelSession(transcript: Transcript(entries: kept))
}
```

A better condensation, when the conversation matters, is to *summarize* the dropped middle with the model itself and inject the summary as a new entry — you spend one extra request to buy back most of your window.

### The error catalogue

`LanguageModelSession.GenerationError` is what you'll be catching. Handle these explicitly, and give each a distinct UI response:

| Error | What happened | What to do |
|---|---|---|
| `.exceededContextWindowSize` | Transcript + prompt + response > window | Condense and restart the session (above) |
| `.guardrailViolation` | Safety system blocked input or output | Neutral, non-accusatory message; offer an alternative (§15) |
| `.unsupportedLanguageOrLocale` | Language the model doesn't support | Hide or disable the feature for that locale (§3) |
| `.assetsUnavailable` | Model assets missing/unloaded | Treat as `.modelNotReady` — transient |
| `.decodingFailure` | Output couldn't be decoded into your type | Usually an over-complex schema — simplify it |
| `.rateLimited` | Too many requests (notably in the background) | Back off and retry |
| `.concurrentRequests` | Two `respond` calls on one session | Gate on `isResponding` |

Tool failures surface separately as a tool-call error wrapping whatever your `call` threw — so the model can't silently swallow a broken tool.

> **Never surface a raw error string.** "The model produced unsafe content" is a bug report, not UI. Every one of these needs a human sentence written by you.

## 15. Safety: guardrails, instructions, and prompt injection

Apple ships built-in **guardrails** that inspect both the input and the output, and throw `.guardrailViolation` when either trips. That's a floor, not a ceiling — Apple's own framing is a "Swiss cheese" model where several imperfect layers overlap:

```
1. Framework guardrails         (Apple's, always on)
2. Your safety instructions     (session-level brief)
3. How you handle user input    (curated → hybrid → raw)
4. Use-case mitigations         (filters, settings, warnings in your domain)
```

### Layer 2 — safety in instructions

Instructions outrank prompts, so this is where your rules live:

```swift
let session = LanguageModelSession {
    "You help people write journal entries by asking about their day."
    "If the user expresses distress, respond with empathy and gentle questions."
    "DO NOT give medical, legal or financial advice."
    "DO NOT discuss self-harm; suggest speaking to someone they trust."
}
```

### Layer 3 — how much user text reaches the model

This is the real architectural decision, and it's a spectrum:

| Pattern | Shape | Risk | When |
|---|---|---|---|
| **Curated** | User picks from prompts you wrote | Lowest | Suggestion chips, canned actions |
| **Hybrid** | Your framing + user's content in a slot | Medium | Summarize *this note*, tag *this photo* |
| **Raw** | User text goes straight through | Highest | Open chat |

Most good features are **hybrid**: the user supplies *content*, you supply the *instruction*.

```swift
// Hybrid: the verb is yours, the noun is theirs.
try await session.respond {
    "Summarize the following note in three sentences. Keep the author's voice."
    "---"
    userNote                      // untrusted content, clearly delimited
    "---"
}
```

> **The cardinal rule, restated because it's the one that gets broken:** user input goes in **prompts**, never in **instructions**. Interpolating user text into instructions hands them the ability to rewrite your app's rules — and there is no layer below that one to catch it.

### Handling a violation

The right response depends on who asked:

```swift
do {
    let response = try await session.respond(to: prompt)
    show(response.content)
} catch LanguageModelSession.GenerationError.guardrailViolation {
    if isProactive {
        // The user didn't ask for this (an auto-generated title, a suggestion).
        // Fail silently — do not interrupt with an error about content they
        // didn't know was being processed.
        return
    } else {
        // The user pressed a button. Acknowledge, don't accuse, offer a way forward.
        showMessage("I can't help with that one — try rephrasing?")
    }
}
```

### Layer 4 — mitigations only you can write

The framework doesn't know your domain. If you generate recipes, allergens are a safety issue and the guardrails have no opinion about them. If you generate trivia, cultural sensitivity is your problem. Typical mitigations: deny-lists for topics, user settings (dietary restrictions, content maturity), UI disclosure that content is generated, and a report mechanism.

**And label it.** Follow the [Human Interface Guidelines for generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai): make it visible that output is machine-generated, make it easy to edit or discard, and never present it as fact.

## 16. Performance: prewarming, token budgets, and Instruments

### Where the time goes

Two distinct latencies, and they have different fixes:

1. **Load time** — the model being paged into memory for the first use. Fix: `prewarm()`.
2. **Inference time** — roughly proportional to **input tokens processed + output tokens generated**. Fix: send less, ask for less.

### `prewarm()`

Call it when you have good reason to think a request is coming — the user opened the compose sheet, focused the text field, navigated to the screen:

```swift
.onAppear { session.prewarm() }
// or, when you already know roughly what you'll ask:
session.prewarm(promptPrefix: Prompt("Summarize this note:"))
```

Prewarming with a prompt prefix also lets the framework start processing the fixed part of your prompt ahead of time. Don't prewarm speculatively all over the app — it's memory and energy, and if the request never comes you've spent both for nothing.

### Spend fewer tokens

- **Instructions are paid on every request.** Tighten them. Three sharp sentences beat a paragraph.
- **Tool descriptions are paid on every request too**, called or not (§12). Fewer, shorter tools.
- **Don't restate schema constraints in prose** (§9).
- **Cap the output** with `maximumResponseTokens` and ask for brevity in words.
- **Prefer guided generation to free text** — a constrained decode emits fewer tokens for the same information.

### Latency you can hide

Streaming (§6, §10) doesn't reduce total time, it reduces *perceived* time, which is what the user experiences. A first field on screen in 400 ms with the rest arriving over three seconds beats a spinner for three seconds, every time.

### Measure it

Xcode ships a **Foundation Models instrument**: time to first token, tokens per second, and per-request breakdown. Profile before you optimize prompts by intuition — the expensive part is often an instruction block you forgot you wrote.

### Energy and background

Inference is real compute. Don't run it in a tight loop, don't run it per keystroke (debounce), and expect `.rateLimited` if you generate aggressively from the background.

## 17. Specialized use cases and custom LoRA adapters

### Built-in use cases

The base model has a couple of pre-tuned variants. The one you'll actually use is **content tagging** — entity and topic extraction, notably better at it than the general model:

```swift
@Generable
struct Tags {
    @Guide(.maximumCount(3)) let topics: [String]
    @Guide(.maximumCount(3)) let actions: [String]
    @Guide(.maximumCount(3)) let emotions: [String]
}

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the most significant topics, actions and emotions in the text."
)
let tags = try await session.respond(to: entry, generating: Tags.self).content
```

If your feature is "turn this text into labels," start here rather than with the general model plus a clever prompt.

### Custom adapters

When prompting genuinely isn't enough — a specialized domain, a house voice, a task with a rigid output convention — Apple publishes an [adapter training toolkit](https://developer.apple.com/apple-intelligence/foundation-models-adapter/). It trains a **LoRA** adapter: the base weights stay frozen and you train a small set of low-rank matrices (rank 32) that ride on top.

```swift
// Loading a trained adapter you've shipped with your app:
let adapter = try SystemLanguageModel.Adapter(name: "MyDomainAdapter")
let model = SystemLanguageModel(adapter: adapter)

// If the adapter ships a draft model for speculative decoding, compile it first.
try await adapter.compile()

let session = LanguageModelSession(model: model)
```

**Read this before you start.** Adapters are a serious commitment, not a tuning knob:

- Training needs a **Python + PyTorch** pipeline and a real, curated dataset.
- The adapter is bound to a **specific base model version**. Apple ships new weights with OS updates, and **your adapter must be retrained and re-shipped each time** or your feature breaks. That's an ongoing operational cost for as long as the feature lives.
- Adapters add to your app's download size.

The honest guidance: exhaust prompt engineering, guided generation with tight `@Guide`s, few-shot examples, and task decomposition first. Those cover the overwhelming majority of cases. Train an adapter only when you have measurements (§18) showing that the ceiling is the model, not your prompt.

## 18. Iterating and testing: Xcode Playgrounds, unit tests, feedback

### Xcode Playgrounds — the tight loop

Prompt iteration through full app rebuilds is agonizing. The `#Playground` macro runs a snippet inline, with results in the canvas, without launching your app:

```swift
import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession(instructions: "You name coffee shops.")
    let a = try await session.respond(to: "A shop on a rainy pier.")
    let b = try await session.respond(to: "A shop inside a bookshop.")
}
```

A `#Playground` block sits in your real project and can see your real types — so you can iterate on the actual `@Generable` type your feature uses, with your actual instructions, and watch what changes when you edit a word. This is where prompt engineering should happen.

### Unit tests

The hard truth first: **you cannot assert on exact model output.** It varies by sampling, and it changes when Apple ships new weights. Test what's actually stable:

```swift
import Testing
@testable import MyApp

@Test func recipeHasUsableStructure() async throws {
    let session = LanguageModelSession(instructions: "You are a cooking assistant.")
    let recipe = try await session.respond(
        to: "Dinner with eggs and spinach",
        generating: Recipe.self,
        options: GenerationOptions(sampling: .greedy)   // repeatable within a model version
    ).content

    // Assert on structure and constraints, never on wording.
    #expect((3...10).contains(recipe.ingredients.count))
    #expect((1...8).contains(recipe.servings))
    #expect(!recipe.title.isEmpty)
}
```

Also test the **unhappy paths**, which are fully deterministic and are where the bugs actually are: availability being unavailable, guardrail violations producing your message rather than a crash, context overflow triggering your condensation path, cancellation leaving clean state. Keep all of that logic outside your views so it's testable without a UI.

### Feedback to Apple

When the model behaves badly in a way you can't fix, file it with the transcript attached:

```swift
// `session` is the session whose last response was wrong.
let attachment = session.logFeedbackAttachment(
    sentiment: .negative,
    issues: [.init(category: .incorrect,
                   explanation: "Invented a trail name despite instructions")]
)
// `attachment` is Data — attach it to a Feedback Assistant report.
```

---

# Part 5 — Reference

## 19. Common mistakes and misconceptions

**"It's a small ChatGPT."** It isn't. It's a ~3B model with thin world knowledge that will invent facts fluently. Design features where *the app supplies the content* and the model transforms it (§2).

**Asking for JSON in the prompt.** Every hour spent coaxing well-formed JSON out of a prompt and parsing it defensively is an hour `@Generable` would have saved, with better accuracy and lower latency (§8).

**Appending stream snapshots.** `text += snapshot.content` duplicates everything. Snapshots are cumulative — always assign (§6).

**Skipping the availability check.** The device that doesn't have Apple Intelligence isn't rare, and "the button does nothing" is the worst possible outcome. Gate at the view level, with three distinct responses for three distinct reasons (§3).

**Putting user input in instructions.** The one genuinely dangerous mistake in the framework. Instructions are your rules; prompts are where user text goes. There is no layer below this one (§15).

**Ignoring the context window until it throws.** In a multi-turn feature, overflow isn't an edge case — it's the destination. Write the condensation path when you write the session, and always keep the first entry (§14).

**Reusing one session for everything.** A session's transcript is a budget you're spending on history you may not need. One session per feature invocation is the default; long-lived sessions need a plan (§4).

**Concurrent requests on one session.** A session handles one request at a time and throws otherwise. Gate the UI on `isResponding`; use separate sessions for genuine concurrency (§4).

**Doing math in the model.** It will produce a number that looks right. Compute in Swift; let the model phrase the result (§2).

**Snapshot-testing model output.** Output changes with sampling, and weights change with OS releases. Test structure and constraints, never wording (§18).

**Showing raw errors.** `guardrailViolation` in an alert is a bug report shown to a user. Every error case needs a sentence you wrote (§14).

**Too many tools, described at length.** Every tool's name and description is paid for on every request, whether it's called or not. Three sharp tools beat ten fuzzy ones (§12).

**Restating `@Guide` constraints in the prompt.** Hard guides are decoder-enforced and unbreakable; repeating them in prose just spends context (§9).

**Reaching for a custom adapter early.** Adapters must be retrained for every OS model update, forever. Exhaust prompting, guides, and decomposition first, and only train against measured evidence (§17).

## 20. Quick reference

**The minimum viable feature:**
```swift
guard SystemLanguageModel.default.isAvailable else { return }
let session = LanguageModelSession(instructions: "…")
let value = try await session.respond(to: prompt, generating: MyType.self).content
```

**Core types:**

| Type | Role |
|---|---|
| `SystemLanguageModel` | The on-device model. `.default`, `.availability`, `.supportedLanguages`, `.contextSize` |
| `LanguageModelSession` | The stateful conversation. `respond`, `streamResponse`, `prewarm`, `transcript`, `isResponding` |
| `Response<Content>` | `.content`, `.rawContent`, `.transcriptEntries` |
| `Transcript` / `Transcript.Entry` | The history, and your context budget |
| `GenerationOptions` | `temperature`, `sampling`, `maximumResponseTokens` |
| `Tool` | `name`, `description`, `@Generable Arguments`, `call(arguments:)` |
| `GenerationSchema` / `DynamicGenerationSchema` | Runtime-built structure |
| `GeneratedContent` | Dynamically-typed result; `value(_:forProperty:)` |

**Macros:**

| Macro | Applies to | Effect |
|---|---|---|
| `@Generable` | struct / enum | Schema + constrained decoding + `PartiallyGenerated` |
| `@Guide` | a property | Description, or a hard decoder constraint |
| `#Playground` | a code block | Inline execution in the Xcode canvas |

**Guides:** `.range(a...b)` · `.minimum(_)` · `.maximum(_)` · `.count(n)` · `.count(a...b)` · `.minimumCount(n)` · `.maximumCount(n)` · `.anyOf([…])` · `Regex { … }` · `description:`

**Errors to catch:** `.exceededContextWindowSize` · `.guardrailViolation` · `.unsupportedLanguageOrLocale` · `.assetsUnavailable` · `.decodingFailure` · `.rateLimited` · `.concurrentRequests`

**Which model?**

| Need | Use |
|---|---|
| Offline, free, private, small tasks | `SystemLanguageModel.default` |
| Entity/topic extraction | `SystemLanguageModel(useCase: .contentTagging)` |
| Domain-specialized, measured need | `SystemLanguageModel(adapter:)` (§17) |

**Decision order for a new feature:**
1. Can a non-AI approach do it? Do that instead.
2. Is it summarize / extract / classify / tag / short compose? → on-device model.
3. Does the output need to be a Swift value? → `@Generable` (it almost always does).
4. Does it need facts or user data? → a tool.
5. Does it take more than a second? → stream partial values.
6. Is it good enough? → test structure and constraints (§18) before shipping.

---

## Sources

**Apple documentation**
- [FoundationModels framework](https://developer.apple.com/documentation/foundationmodels) · [`LanguageModelSession`](https://developer.apple.com/documentation/foundationmodels/languagemodelsession) · [`SystemLanguageModel`](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel)
- [Adding intelligent app features with generative models](https://developer.apple.com/documentation/foundationmodels/adding-intelligent-app-features-with-generative-models)
- [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output)
- [Generate dynamic game content with guided generation and tools](https://developer.apple.com/documentation/foundationmodels/generate-dynamic-game-content-with-guided-generation-and-tools)
- [Foundation Models adapter training](https://developer.apple.com/apple-intelligence/foundation-models-adapter/)
- [Human Interface Guidelines — Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)

**WWDC sessions** (the primary sources behind this guide)
- WWDC25 — [Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/) · [Deep dive into the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/301/) · [Explore prompt design & safety for on-device foundation models](https://developer.apple.com/videos/play/wwdc2025/248/)

**Community references**
- [Create with Swift — Exploring the Foundation Models framework](https://www.createwithswift.com/exploring-the-foundation-models-framework/)
- [AzamSharp — The Ultimate Guide to the Foundation Models Framework](https://azamsharp.com/2025/06/18/the-ultimate-guide-to-the-foundation-models-framework.html)
- [Swift with Majid — Building AI features using Foundation Models: Streaming](https://swiftwithmajid.com/2025/10/08/building-ai-features-using-foundation-models-streaming/)
- Local companions in this folder: `swift6_sendable_tutorial.md` (concurrency vocabulary this guide assumes), `arkit_realitykit_tutorial.md`

---

*Written against the iOS/iPadOS/macOS/visionOS 26 SDKs (Xcode 26, Swift 6.2), current as of mid-2026. Every code block was verified to compile against the shipping `FoundationModels` module using a companion Swift package (Xcode 26, macOS 26 SDK).*
