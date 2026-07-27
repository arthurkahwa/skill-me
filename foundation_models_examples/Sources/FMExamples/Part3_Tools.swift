import FoundationModels
import WeatherKit
import CoreLocation

// §12 — Tool calling

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Get the current weather for a named city."

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

    func call(arguments: Arguments) async throws -> String {
        // Always return something the model can use, even on a miss (§12).
        guard let coordinate = Self.coordinates[arguments.city.lowercased()] else {
            return "No weather data for \(arguments.city)."
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await WeatherService.shared.weather(for: location)
        return "\(arguments.city): \(weather.currentWeather.temperature.formatted()), " +
               "\(weather.currentWeather.condition.description)"
    }
}

enum Tools12 {
    static func register() async throws {
        let session = LanguageModelSession(
            tools: [GetWeatherTool()],
            instructions: "You help people plan their day. Use tools to get real information."
        )

        let response = try await session.respond(to: "Should I cycle to work in Munich today?")
        _ = response
    }
}

// Stateful tool — dedup state kept in an actor so the Tool stays Sendable.

struct Photo: Sendable, Identifiable {
    let id: String
    let caption: String
}

struct PhotoLibrary: Sendable {
    func search(_ description: String) async throws -> [Photo] { [] }
}

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

    @Generable struct Arguments {
        let description: String
    }

    func call(arguments: Arguments) async throws -> String {
        let candidates = try await library.search(arguments.description)
        guard let pick = await returned.pick(from: candidates) else {
            return "No matching photo found."
        }
        return pick.caption
    }
}
