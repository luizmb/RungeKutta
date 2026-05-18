// swift-tools-version: 5.10

import PackageDescription

let customOperator: [Target] = [
    .target(name: "CompositionOperators", dependencies: ["Monoid", "Morphisms"]),
    .target(name: "FoundationCategoryTheoryOperators", dependencies: ["FoundationCategoryTheory", "CompositionOperators"]),
    .target(name: "MathOperators", dependencies: ["Math"])
]

let calculus: [Target] = [
    .target(name: "RungeKutta", dependencies: ["Calculus"]),
    .target(name: "Calculus", dependencies: ["Math", "Morphisms"]),
    .target(name: "Math", dependencies: ["RealNumber"]),
    .target(name: "Morphisms", dependencies: ["Monoid"]),
    .target(name: "RealNumber")
]

let categoryTheory: [Target] = [
    .target(name: "FoundationCategoryTheory", dependencies: ["Monoid"])
]

let shared: [Target] = [
    .target(name: "Monoid")
]

let package = Package(
    name: "SwiftMath",
    products: [
        .library(name: "Calculus", targets: ["Calculus", "MathOperators", "CompositionOperators"]),
        .library(name: "CalculusNoOperators", targets: ["Calculus"]),
        .library(name: "FoundationCategoryTheory", targets: ["FoundationCategoryTheory", "FoundationCategoryTheoryOperators"]),
        .library(name: "FoundationCategoryTheoryNoOperators", targets: ["FoundationCategoryTheory", "Monoid", "Morphisms"]),
        .library(name: "RungeKutta",targets: ["RungeKutta", "MathOperators", "CompositionOperators"]),
        .library(name: "SwiftMath", targets: ["SwiftMath"])
    ],
    targets: customOperator + calculus + categoryTheory + shared + [
        .target(name: "SwiftMath", dependencies: ["RungeKutta", "FoundationCategoryTheoryOperators", "MathOperators"]),
        .testTarget(name: "CalculusTests", dependencies: ["Calculus", "MathOperators"]),
        .testTarget(name: "CompositionOperatorsTests", dependencies: ["CompositionOperators"]),
        .testTarget(name: "FoundationCategoryTheoryOperatorsTests", dependencies: ["FoundationCategoryTheoryOperators"]),
        .testTarget(name: "FoundationCategoryTheoryTests", dependencies: ["FoundationCategoryTheory"]),
        .testTarget(name: "MathOperatorsTests", dependencies: ["MathOperators"]),
        .testTarget(name: "MathTests", dependencies: ["Math"]),
        .testTarget(name: "MonoidTests", dependencies: ["Monoid"]),
        .testTarget(name: "MorphismsTests", dependencies: ["Morphisms"]),
        .testTarget(name: "RealNumberTests", dependencies: ["RealNumber"]),
        .testTarget(name: "RungeKuttaTests", dependencies: ["RungeKutta"])
    ]
)
