Write a comprehensive, example-driven tutorial on Apple's Foundation Models
framework (the on-device LLM Swift API behind Apple Intelligence).

Audience: an experienced Swift/SwiftUI developer who knows async/await and
actor isolation but has never used an LLM API.

Version posture: write against the shipping 26 SDKs (iOS/iPadOS/macOS/visionOS
26, Xcode 26, Swift 6.2). Put every WWDC26 / 27-line addition (multimodal
prompts, Private Cloud Compute, the LanguageModel protocol, Dynamic Profiles,
Evaluations, fm CLI) in a clearly-marked beta section near the end. Research
the current APIs on the web first — do not write from memory — and cite Apple
docs and WWDC sessions inline.

Format:
- Markdown, ~25 numbered sections grouped into named Parts, with a linked table
  of contents and a blockquote preamble stating version, how to read it, and
  primary sources.
- Every code block preceded by what it does and why. Never introduce an API
  without naming and explaining it on first use.
- Use tables for anything comparative (decision matrices, error catalogues,
  option trade-offs).
- Use "> **Callout.**" blockquotes for foot-guns and version caveats.
- One self-contained runnable SwiftUI capstone that combines everything:
  availability gating, prewarm, a @Generable type with @Guide constraints, a
  custom Tool, streamed partial values, typed error handling, cancellation.
- End with a "common mistakes" section and a quick-reference section (core
  types, macros, guides, errors, decision order), then a Sources list.

Cover, at minimum: what the framework is and isn't; the model's real
capabilities and limits; availability checking and the three unavailable
reasons; LanguageModelSession, instructions vs prompts, prompt builders;
streaming and cumulative snapshots; GenerationOptions; @Generable and
constrained decoding; @Guide hard vs soft constraints; PartiallyGenerated;
dynamic schemas; tool calling; context windows and transcript condensation;
the GenerationError catalogue; guardrails and prompt injection; performance
and prewarming; content-tagging use case and LoRA adapters; #Playground and
how to test something non-deterministic.

Code quality bar:
- Verify the code for functionality before you write it.
- Make sure the code does not have to be debugged by the one following the
  tutorial.
- Make sure the code compiles before writing.
- Make sure there is no "magic" code — prefer complete, end-to-end examples
  to code snippets that are unconnected to any code.
