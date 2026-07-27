import FoundationModels
import SwiftUI

// §14 — Context windows, transcripts, errors

enum Shipping14 {
    // The transcript IS the collection of entries — iterate it directly.
    static func inspectTranscript(_ session: LanguageModelSession) {
        for entry in session.transcript {
            print(entry)   // .instructions, .prompt, .response, .toolCalls, .toolOutput
        }
    }

    // Measuring the budget directly (iOS/macOS 26.4+).
    static func measure(_ session: LanguageModelSession) async throws {
        let model = SystemLanguageModel.default
        _ = model.contextSize
        let used = try await model.tokenCount(for: session.transcript)
        _ = used
    }

    // Recovering from an overflow.
    static func recover(_ session: inout LanguageModelSession, prompt: String) async throws {
        do {
            let answer = try await session.respond(to: prompt)
            _ = answer
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            session = condensed(from: session)
        }
    }

    static func condensed(from old: LanguageModelSession) -> LanguageModelSession {
        let entries = Array(old.transcript)
        var kept: [Transcript.Entry] = []

        // ALWAYS keep the first entry — that's your instructions.
        if let first = entries.first { kept.append(first) }
        if let last = entries.last, entries.count > 1 { kept.append(last) }

        return LanguageModelSession(transcript: Transcript(entries: kept))
    }
}

// §15 — Safety

@Observable
@MainActor
final class JournalModel {
    private let session = LanguageModelSession {
        "You help people write journal entries by asking about their day."
        "If the user expresses distress, respond with empathy and gentle questions."
        "DO NOT give medical, legal or financial advice."
        "DO NOT discuss self-harm; suggest speaking to someone they trust."
    }

    private(set) var message: String = ""

    // Hybrid: the verb is yours, the noun is theirs.
    func summarize(_ userNote: String) async throws {
        message = try await session.respond {
            "Summarize the following note in three sentences. Keep the author's voice."
            "---"
            userNote                      // untrusted content, clearly delimited
            "---"
        }.content
    }

    // Handling a violation depends on who asked.
    func run(prompt: String, isProactive: Bool) async {
        do {
            let response = try await session.respond(to: prompt)
            message = response.content
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            if isProactive {
                return                    // fail silently — the user didn't ask
            } else {
                message = "I can't help with that one — try rephrasing?"
            }
        } catch {
            message = "Something went wrong."
        }
    }
}

// §16 — Performance

struct PrewarmView: View {
    let session: LanguageModelSession
    var body: some View {
        Text("Compose")
            .onAppear { session.prewarm() }
    }
}

enum Perf16 {
    static func prewarmWithPrefix(_ session: LanguageModelSession) {
        session.prewarm(promptPrefix: Prompt("Summarize this note:"))
    }
}

// §17 — Specialized use cases and custom adapters

@Generable
struct Tags {
    @Guide(.maximumCount(3)) let topics: [String]
    @Guide(.maximumCount(3)) let actions: [String]
    @Guide(.maximumCount(3)) let emotions: [String]
}

enum Specialized17 {
    static func contentTagging(entry: String) async throws {
        let session = LanguageModelSession(
            model: SystemLanguageModel(useCase: .contentTagging),
            instructions: "Tag the most significant topics, actions and emotions in the text."
        )
        let tags = try await session.respond(to: entry, generating: Tags.self).content
        _ = tags
    }

    static func loadAdapter() async throws {
        let adapter = try SystemLanguageModel.Adapter(name: "MyDomainAdapter")
        let model = SystemLanguageModel(adapter: adapter)

        try await adapter.compile()

        let session = LanguageModelSession(model: model)
        _ = session
    }
}

// §18 — Feedback to Apple

enum Feedback18 {
    static func logNegative(_ session: LanguageModelSession) {
        let attachment = session.logFeedbackAttachment(
            sentiment: .negative,
            issues: [.init(category: .incorrect,
                           explanation: "Invented a trail name despite instructions")]
        )
        // Attach `attachment` (Data) to a Feedback Assistant report.
        _ = attachment
    }
}
