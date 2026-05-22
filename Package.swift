// swift-tools-version: 6.2

import PackageDescription

let customOperator: [Target] = [
    .target(
        name: "MathOperators",
        dependencies: [
            "Math",
            .product(name: "CoreFPOperators", package: "FP")
        ]
    )
]

// System OpenBLAS — Linux-only, depended on by Math only on Linux. Apple
// consumers never pull this in transitively (Accelerate handles their fast
// path); pkg-config is only invoked when Math actually builds the dep, which
// only happens on Linux. See Sources/COpenBLAS/module.modulemap.
let copenblas: [Target] = [
    .systemLibrary(
        name: "COpenBLAS",
        pkgConfig: "openblas",
        providers: [
            .apt(["libopenblas-dev"]),
            .yum(["openblas-devel"])
        ]
    )
]

let calculus: [Target] = [
    .target(name: "RungeKutta", dependencies: ["Calculus"]),
    .target(
        name: "Calculus",
        dependencies: [
            "Math",
            .product(name: "CoreFP", package: "FP")
        ]
    ),
    .target(
        name: "Math",
        dependencies: [
            "RealNumber",
            .product(name: "CoreFP", package: "FP"),
            .target(name: "COpenBLAS", condition: .when(platforms: [.linux]))
        ]
    ),
    .target(name: "RealNumber")
]

let package = Package(
    name: "SwiftCalx",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Math", targets: ["Math", "MathOperators"]),
        .library(name: "MathNoOperators", targets: ["Math"]),
        .library(name: "Calculus", targets: ["Calculus", "MathOperators"]),
        .library(name: "CalculusNoOperators", targets: ["Calculus"]),
        .library(name: "RungeKutta", targets: ["RungeKutta", "MathOperators"]),
        .library(name: "SwiftCalx", targets: ["SwiftCalx"])
    ],
    dependencies: [
        .package(url: "https://github.com/luizmb/FP.git", from: "1.8.1"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: customOperator + copenblas + calculus + [
        .target(name: "SwiftCalx", dependencies: ["RungeKutta", "MathOperators"]),
        .testTarget(name: "CalculusTests", dependencies: ["Calculus", "MathOperators"]),
        .testTarget(name: "MathOperatorsTests", dependencies: ["MathOperators"]),
        .testTarget(name: "MathTests", dependencies: ["Math", "MathOperators"]),
        .testTarget(name: "RealNumberTests", dependencies: ["RealNumber"]),
        .testTarget(name: "RungeKuttaTests", dependencies: ["RungeKutta"])
    ]
)
