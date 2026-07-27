# Foundation Models Examples

Compile-verification harness for [`../foundation_models_tutorial.md`](../foundation_models_tutorial.md).

Every code example in the tutorial has a counterpart here that **compiles against the
shipping `FoundationModels` module** (Xcode 26, macOS 26 SDK, Swift 6). The point is
that nothing in the tutorial is invented or pseudo-code — if it's in the guide, it builds.

## Build

```bash
swift build            # compiles all examples (Parts 0–4) + the #Playground macro
swift build --build-tests   # also compiles the §18 unit-test example
```

`swift build` type-checks and compiles everything. It does **not** run the model —
running actually needs an Apple-Intelligence-capable device with the model downloaded.
The `§18` test likewise compiles here but only *passes* when run on such a device.

## Layout

| File | Tutorial sections |
|------|-------------------|
| `Sources/FMExamples/Part0_Availability.swift` | §3 availability gating |
| `Sources/FMExamples/Part1_Core.swift`         | §4–7 sessions, prompting, streaming, options |
| `Sources/FMExamples/Part2_Structured.swift`   | §8–11 `@Generable`, `@Guide`, streaming, dynamic schemas |
| `Sources/FMExamples/Part3_Tools.swift`        | §12 tool calling |
| `Sources/FMExamples/Part3_Capstone.swift`     | §13 the complete "Cook What I Have" feature |
| `Sources/FMExamples/Part4_Shipping.swift`     | §14–18 context, safety, performance, adapters, feedback |
| `Sources/FMExamples/Part4_Playground.swift`   | §18 `#Playground` |
| `Tests/FMExamplesTests/FeatureTests.swift`    | §18 structure-only unit test |

Illustrative one-liners in the tutorial (e.g. a bare `respond { … }` given "a `session`")
are wrapped in small functions here so they have a place to live and compile.
