import FoundationModels
import SwiftUI

// §3 — Availability: check before you build UI on it

enum Availability3 {
    static func fullSwitch() {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            break
        case .unavailable(.appleIntelligenceNotEnabled):
            break
        case .unavailable(.modelNotReady):
            break
        case .unavailable(let other):
            print("Unavailable: \(other)")
        }
    }

    static func convenienceAndLanguage() {
        let model = SystemLanguageModel.default
        if model.isAvailable { /* … */ }

        guard model.supportedLanguages.contains(Locale.current.language) else {
            return
        }
        _ = model
    }
}

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
            EmptyView()
        }
    }

    func summarize() { /* … */ }
}
