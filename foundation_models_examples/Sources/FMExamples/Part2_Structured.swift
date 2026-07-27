import FoundationModels
import SwiftUI
import RegexBuilder

// §8 — @Generable: guided generation

@Generable
struct Recipe {
    let title: String
    let servings: Int
    let ingredients: [String]
    let steps: [String]
}

enum Structured8 {
    static func generate(_ session: LanguageModelSession) async throws {
        let response = try await session.respond(
            to: "Invent a weeknight dinner using eggs, spinach and feta.",
            generating: Recipe.self
        )

        let recipe = response.content
        print(recipe.servings + 2)
    }
}

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

@Generable
struct OutlineNode {
    let heading: String
    let children: [OutlineNode]
}

// §9 — @Guide: constraining individual fields

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

@Generable
struct Contact {
    @Guide(Regex {
        Capture { ChoiceOf { "Dr"; "Mr"; "Ms" } }
        ". "
        OneOrMore(.word)
    })
    let name: String
}

// §10 — PartiallyGenerated: streaming a structure

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
            partial = snapshot.content
        }
    }
}

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

// §11 — Dynamic schemas: structure decided at runtime

enum Dynamic11 {
    static func riddle(_ session: LanguageModelSession) async throws {
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

        let schema = try GenerationSchema(root: riddle, dependencies: [answer])

        let response = try await session.respond(to: "Generate a riddle about coffee", schema: schema)

        let question = try response.content.value(String.self, forProperty: "question")
        let answers  = try response.content.value([GeneratedContent].self, forProperty: "answers")
        _ = (question, answers)
    }
}
