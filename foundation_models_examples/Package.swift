// swift-tools-version: 6.0
import PackageDescription

// Compile-verification package for `foundation_models_tutorial.md`.
// Every code example in the tutorial has a counterpart here that builds
// against the shipping FoundationModels module (Xcode 26, macOS 26 SDK).
let package = Package(
    name: "FoundationModelsExamples",
    platforms: [.macOS("26.4")],
    targets: [
        .target(name: "FMExamples"),
        .testTarget(name: "FMExamplesTests", dependencies: ["FMExamples"]),
    ]
)
