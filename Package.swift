// swift-tools-version: 6.2

import PackageDescription

// MARK: - (Swift settings)

enum UpcomingFeature: String, CaseIterable {

    case approachableConcurrency = "ApproachableConcurrency"

    case existentialAny = "ExistentialAny"

    case immutableWeakCaptures = "ImmutableWeakCaptures"

    case inferIsolatedConformances = "InferIsolatedConformances"

    case internalImportsByDefault = "InternalImportsByDefault"

    case memberImportVisibility = "MemberImportVisibility"

    case nonisolatedNonsendingByDefault = "NonisolatedNonsendingByDefault"
}

func swiftSettings(
    defaultIsolation: MainActor.Type? = MainActor.self,
    strictMemorySafety: Bool = true,
    enabledUpcomingFeatures: [UpcomingFeature] = UpcomingFeature.allCases
) -> [SwiftSetting] {
    var settings = [SwiftSetting]()
    if let isolation = defaultIsolation {
        settings.append(.defaultIsolation(isolation))
    }
    if strictMemorySafety {
        settings.append(.strictMemorySafety())
    }
    settings.append(
        contentsOf:
            enabledUpcomingFeatures.map({.enableUpcomingFeature($0.rawValue)}),
    )
    return settings
}

// MARK: - (Package)

let package: Package = .init(
    name: "uritsort",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "uritsort",
            targets: ["TopologicalSortCommand"],
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.8.2",
        ),
    ],
    targets: [
        .executableTarget(
            name: "TopologicalSortCommand",
            dependencies: [
                "TopologicalSort",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser",
                ),
            ],
            swiftSettings: swiftSettings(),
        ),
        .target(
            name: "TopologicalSort",
            swiftSettings: swiftSettings(defaultIsolation: nil),
        ),
        .testTarget(
            name: "TopologicalSortCommandTests",
            dependencies: ["TopologicalSortCommand"],
            swiftSettings: swiftSettings(),
        ),
        .testTarget(
            name: "TopologicalSortTests",
            dependencies: ["TopologicalSort"],
            swiftSettings: swiftSettings(defaultIsolation: nil),
        ),
    ],
)
