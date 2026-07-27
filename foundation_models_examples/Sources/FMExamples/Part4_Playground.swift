import FoundationModels
import Playgrounds

// §18 — Xcode Playgrounds: the tight loop

#Playground {
    let session = LanguageModelSession(instructions: "You name coffee shops.")
    let a = try await session.respond(to: "A shop on a rainy pier.")
    let b = try await session.respond(to: "A shop inside a bookshop.")
}
