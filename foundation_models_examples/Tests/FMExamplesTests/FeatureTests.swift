import Testing
import FoundationModels
@testable import FMExamples

// §18 — Unit tests: assert on structure and constraints, never on wording.

@Test func recipeHasUsableStructure() async throws {
    let session = LanguageModelSession(instructions: "You are a cooking assistant.")
    let recipe = try await session.respond(
        to: "Dinner with eggs and spinach",
        generating: Recipe.self,
        options: GenerationOptions(sampling: .greedy)   // repeatable within a model version
    ).content

    #expect((3...10).contains(recipe.ingredients.count))
    #expect((1...8).contains(recipe.servings))
    #expect(!recipe.title.isEmpty)
}
