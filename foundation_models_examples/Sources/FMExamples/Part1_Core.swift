import FoundationModels
import SwiftUI

// §4 — LanguageModelSession: instructions, prompts, responses

struct FindTrailTool: Tool {
    let name = "findTrail"
    let description = "Find a hiking trail by name or area."
    @Generable struct Arguments {
        @Guide(description: "A place or area name") let area: String
    }
    func call(arguments: Arguments) async throws -> String {
        "No trail data available for \(arguments.area)."
    }
}

enum Core4 {
    static func multiTurn() async throws {
        let session = LanguageModelSession(
            instructions: """
                You are a concise assistant inside a hiking app.
                Answer in one or two sentences. Never invent trail names.
                """
        )
        let first  = try await session.respond(to: "What should I pack for a rainy day hike?")
        let second = try await session.respond(to: "What about in winter?")
        _ = (first, second)
    }

    static func creatingSessions() {
        let bare = LanguageModelSession()

        let session = LanguageModelSession(
            model: SystemLanguageModel.default,
            tools: [FindTrailTool()],
            instructions: "You help plan day hikes."
        )
        _ = (bare, session)
    }

    static func inspecting(_ session: LanguageModelSession) {
        _ = session.isResponding
        _ = session.transcript
        session.prewarm()
    }
}

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

// §5 — Prompting: builders, instructions vs prompts

struct RecipeUser {
    var prefersMetric = false
    var allergy: String?
}

enum Prompt5 {
    static func builders(user: RecipeUser, ingredients: [String]) async throws {
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
        _ = response
    }

    static func showDontExplain(_ session: LanguageModelSession, title: String) async throws {
        _ = try await session.respond {
            "Rewrite each title in sentence case."
            "Example: 'THE BEST HIKES' -> 'The best hikes'"
            "Example: 'a walk in fog' -> 'A walk in fog'"
            "Now rewrite: \(title)"
        }
    }
}

// §6 — Streaming into SwiftUI

@Observable
@MainActor
final class StoryModel {
    private let session = LanguageModelSession(instructions: "You write short bedtime stories.")
    private(set) var text: String = ""

    func write(about subject: String) async throws {
        let stream = session.streamResponse(to: "Write a bedtime story about \(subject).")
        for try await snapshot in stream {
            text = snapshot.content
        }
    }
}

struct StoryView: View {
    @State private var model = StoryModel()

    var body: some View {
        ScrollView {
            Text(model.text)
                .animation(.easeOut, value: model.text)
        }
        .task { try? await model.write(about: "a fox who can't sleep") }
    }
}

enum Stream6 {
    static func collectFinal(_ session: LanguageModelSession, prompt: String) async throws {
        let stream = session.streamResponse(to: prompt)
        let final = try await stream.collect()
        _ = final.content
    }
}

// §7 — GenerationOptions

enum Options7 {
    static func perRequest(_ session: LanguageModelSession, prompt: String) async throws {
        let response = try await session.respond(
            to: prompt,
            options: GenerationOptions(temperature: 0.4, maximumResponseTokens: 300)
        )
        _ = response

        _ = GenerationOptions(sampling: .greedy)
        _ = GenerationOptions(sampling: .random(top: 40))
        _ = GenerationOptions(sampling: .random(probabilityThreshold: 0.9))

        _ = GenerationOptions(temperature: 0.2, maximumResponseTokens: 200)
        _ = GenerationOptions(maximumResponseTokens: 500)
    }
}
