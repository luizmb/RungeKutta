# What's left — RungeKutta + neighbours

Snapshot: 2026-05-21. The original "migration plan" (strip RungeKutta down to math + calculus + RK, point at FP for the plumbing) is complete. This file now tracks the remaining work — rename / split / consumer coordination — and the deferred design notes.

## ✅ Completed

- **Phase A — FP-duplicate purge (2026-05-19)**. Deleted five modules whose responsibilities now live in `FP`:
  `Monoid`, `Morphisms`, `FoundationCategoryTheory`, `FoundationCategoryTheoryOperators`, `CompositionOperators`.
  Also deleted the small helpers that had already been ported into FP:
  `Comparable.clamped`/`within`, `Array.cartesian`, `Strideable.plusMinus`, `≅` (approximate equality).
  `Math` now depends on `CoreFP`; `MathOperators` on `CoreFPOperators`.
- **Phase B — RK4 correctness + Vector RK (2026-05-18)**. Fixed the RK4 double-add bug (`rk4` now returns pure Δy; `calculateNextPoint` does the single `lastPoint.y + Δy`). Added the `VectorState` protocol + vector-state `rk4` overload. Replaced the stub `RungeKuttaTests` with real scalar + vector + trajectory test files.
- **Math + algorithm namespaces (2026-05-19)**. Added `Math.Matrix<T: ℝ>` (`+`, `*`, scalar `*`, `apply(to:)`, `with(row:column:value:)`, `squared(times:)`); the `⋅` operator wraps `*` / `apply(to:)`. Extracted `Calculus.SimpsonWeightedAverage` (used by both scalar and vector RK4) and `Calculus.Taylor` (matrix-exponential building block). Added `RungeKutta4.trajectory(from:derivative:step:through:)` for one-shot integration.
- **`DerivativeFunction` bug-fixes (2026-05-19)**. `CentralStencil.fivePoint` lost its bogus `fifthPoint` truncation term (`fn(5)` was evaluating the function at literal `5`, not a 4th derivative). `isDifferentiable(at:h:)` rewritten with `√h` tolerance (corners and vertical tangents now detected). `invert()` renamed to `perpendicularSlope()` (the old name implied function inversion; it actually returns `−1 / self(x)`).
- **CalculusPlayground deleted (2026-05-19)**. Referenced an API removed years ago and hadn't compiled since.
- **Sendable cascade (2026-05-21, [PR #1](https://github.com/luizmb/RungeKutta/pull/1))**. Bumped FP to 1.8.1. `protocol ℝ` and `protocol VectorState` refine `Sendable`. `BidimensionalPoint`, `TridimensionalPoint`, `Fibonacci`, `Fibonacci.Method`, `DerivativeFunction` gain conditional `Sendable` conformance. `DerivativeMethod` already stored its `deriving` closure as `@Sendable`.

## Current layout

```
Math/
  Matrix<Scalar: ℝ>            // row-major matrix + +, *, scalar *, apply(to:), with, squared
  VectorState                  // protocol over an ℝ scalar; built-in conformances for [T] and concrete ℝs
  BidimensionalPoint, TridimensionalPoint, slope
  Log, Numeric+, Symbols

MathOperators/
  Matrix+Operators             // ⋅ (DOT OPERATOR) for matrix-matrix, scalar-matrix, matrix-vector
  ≅, ±, +/-, √, ^^

Calculus/
  SimpsonWeightedAverage       // (v1 + 2v2 + 2v3 + v4) / 6 — used by RK4
  Taylor                       // matrix Taylor series of exp (generic building block)
  Derivative, DerivativeMethod, Fibonacci, Fn

RungeKutta/
  RungeKutta4                  // scalar + vector overloads; both delegate to SimpsonWeightedAverage
  RungeKutta4.trajectory(…)    // one-shot integrator returning [(time, state)]
```

Birchall's scaling-and-squaring matrix-exponential lives in the dosimetry consumer (`MultiCompartmentModel/Sources/MultiCompartmentModel/Birchall.swift`) because Birchall 1986 published it specifically for compartmental dosimetry models. The generic building blocks it composes — `Math.Matrix`, `Matrix.squared(times:)`, `Calculus.Taylor.exponential` — stay here. If a non-Birchall scaling-and-squaring variant (Padé, Moler & Van Loan algorithm 11, etc.) is ever needed in pure numerical linear algebra, it lands here under its own namespace.

Conventions:
- Algorithm-named static functions live under `enum AlgorithmName { static func … }`. If a sub-step has a known mathematical / historical name, give it its own namespace (`SimpsonWeightedAverage`, `Taylor`, `Birchall`); otherwise leave as a private helper inside the parent algorithm.
- Docs are written for non-mathematicians: explain the concept, link to the canonical text (Butcher, Moler–Van Loan, Birchall 1986, Strang, Wikipedia), walk through the algorithm.
- Custom mathematical symbols are welcome (`⋅`, `√`, `^^` already ship). The convention is *named function first, operator as ergonomic alias second*.

---

## ⏳ Pending

### Library rename
The `RungeKutta` / `SwiftMath` umbrella names no longer describe the breadth — the package now hosts `Math.Matrix`, `Calculus.Taylor`, `Calculus.SimpsonWeightedAverage`, `Calculus.DerivativeMethod`, `RungeKutta4`, plus trajectory + Fibonacci. Candidate names: `Calculus`, `SwiftNumerics`, `Numerics` (or something fresher). **Decide later.** The rename touches the GitHub repo URL, every consumer's `Package.swift` (`MultiCompartmentModel`, future consumers), and the SwiftPM resolved cache. Coordinate with the **MCM → BiokineticModels** rename (below) so consumers swap both at once.

### Break the package down
Once renamed, consider splitting into smaller packages along module lines:
- `Math` — Matrix, VectorState, BidimensionalPoint, TridimensionalPoint
- `MathOperators` — `⋅`, `≅`, `±`, etc.
- `Calculus` — Taylor, SimpsonWeightedAverage, Derivative, DerivativeMethod, Fibonacci, Fn
- `RungeKutta` — RungeKutta4 + Trajectory

Lets consumers pull only what they need (the dosimetry package currently drags the whole umbrella in for Matrix + Taylor + RK4) and lets future FP-duplicate purges happen one package at a time. Trade-off: more `Package.swift` files to maintain.

### MCM → BiokineticModels (consumer-side, jointly coordinated)
The dosimetry consumer at `github.com:luizmb/MultiCompartmentModel.git` should be renamed to `BiokineticModels` (or similar) to describe its breadth: it hosts the compartmental model loader, the Birchall solver, the `SolverMethod` dispatch, and future dose / SEE calculations. Coordinate the GitHub rename, `Package.swift` `name:` field, target/product names, import paths, and the `.package(path: "../RungeKutta")` line (which becomes `.package(url: "https://github.com/luizmb/<new-name>.git", from: "<tagged>")` once Phase B is published).

### Open design choices (not bugs)

- **`DerivativeFunction.differentiate()` higher-order.** Currently re-applies the same `Method` to the already-derived slope function. Works in theory; step-size error compounds fast. The agreed direction (this session) is to refactor `DerivativeMethod` from instance-based witness to a **type-level protocol witness** where `order` and the deriving algorithm are *static computed properties* on per-method struct types, plus add **Fornberg's algorithm** (1988) so any `(points, order)` combination is one general implementation rather than a hand-written stencil. The existing `CentralStencil`/`ForwardStencil`/`BackwardStencil` cases become parameter combinations.
- **State shape for biokinetics / multi-compartment.** When wiring RK4 into a multi-compartment model, per-compartment RK4 with externally-coupled inputs gives the wrong answer — coupled linear ODEs `dy⃗/dt = A·y⃗ + u⃗(t)` need all compartments advanced together at every substep. The generic-state shape (`VectorState`) we shipped is the right answer; a fixed-width SIMD variant is faster but locks the compartment count at compile time. Defer SIMD until profiling demands it. Because ICRP biokinetic systems are linear with constant rate constants, the **analytic** option `y(t) = exp(A·t) · y₀` is also available (already shipped via `Birchall` + `Math.Matrix.squared(times:)`); useful as a ground-truth oracle for RK4 tests and a faster path when intermediate trajectories aren't needed.

### Known-and-documented limitations (not TODOs)

- **Fibonacci `.quick`** (the Binet-via-`cos` form) drifts hard once `n > ~60`; `testCompareFiboAlgorithmPrecision` already accepts `accuracyQuick = 1e7` past index 90. Documented as a curiosity; for arbitrary precision, prefer `Decimal` or genuine bignum.
