import FoundationModels
import SwiftUI

// §13 — Capstone: "Cook What I Have"

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

struct PantryTool: Tool {
    let name = "checkPantry"
    let description = "Check whether a staple ingredient is already in the user's pantry."

    let pantry: Set<String>

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

@Observable
@MainActor
final class CookModel {
    enum State: Equatable {
        case idle
        case unavailable(String)
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

        switch SystemLanguageModel.default.availability {
        case .available:
            session = makeSession()
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
                    options: GenerationOptions(temperature: 0.6, maximumResponseTokens: 600)
                )
                for try await snapshot in stream {
                    self.recipe = snapshot.content
                }
                self.state = .done
            } catch is CancellationError {
                self.state = .idle
            } catch LanguageModelSession.GenerationError.guardrailViolation {
                self.state = .failed("Let's try that with different ingredients.")
            } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
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
