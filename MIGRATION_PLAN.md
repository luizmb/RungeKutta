# RungeKutta → FP migration plan & next-steps notes

Snapshot: 2026-05-19. RungeKutta has 11 source modules; FP (`~/code/FP`) now supersedes the FP/category-theory subset. Goal: strip RungeKutta down to math + calculus + RK, pointing at FP for the plumbing.

## Status

- ✅ **Phase B (2026-05-18)** — fixed the `rk4` double-add bug; added `VectorState` protocol + vector-state `rk4` overload; replaced the empty `RungeKuttaTests` stub with 11 real scalar + vector tests.
- ✅ **Math + algorithm namespaces (2026-05-19)** — added `Matrix<T: ℝ>` value type with `+`, `*`, scalar `*`, `apply(to:)`, `with(row:column:value:)`, `squared(times:)`; the `⋅` (DOT OPERATOR) operator wraps `*` / `apply(to:)`; extracted `SimpsonWeightedAverage` (used by both scalar and vector RK4) and `Taylor` algorithm namespaces under `Calculus/`. Added `RungeKutta4.trajectory(from:derivative:step:through:)` for one-shot integration. Renamed nothing in the public RK4 API.
- ✅ **Birchall lives in MultiCompartmentModel, not here** — Birchall's 1986 algorithm is the dosimetry-specific scaling-and-squaring matrix exponential. The generic building blocks (`Math.Matrix`, `Math.Matrix.squared(times:)`, `Calculus.Taylor.exponential`) stay in this library; the dosimetry-flavored composition lives in `MultiCompartmentModel/Sources/MultiCompartmentModel/Birchall.swift`. If/when a non-Birchall scaling-and-squaring variant (Padé, Moler & Van Loan algorithm 11, etc.) is needed in pure numerical linear algebra, it lands here under its own algorithm namespace.
- ✅ **FP-duplicate removal (2026-05-19)** — deleted the 5 obsolete modules (`Monoid`, `Morphisms`, `FoundationCategoryTheory`, `FoundationCategoryTheoryOperators`, `CompositionOperators`) plus their stub test targets; added `FP` as a SwiftPM dependency; refactored `Calculus/Fn.swift` to alias `Endo<T>` from `CoreFP`; updated `Calculus/Derivative.swift` and `Calculus/Fibonacci.swift` accordingly. Bumped platforms to FP's minimums (macOS 10.15+, iOS 13+). The package is still named `SwiftMath`/`RungeKutta` — the rename is its own item (below).
- ⏳ **Library rename** — eventually rename the whole package (the namespaces now include `Math.Matrix`, `Calculus.Taylor`, `Calculus.SimpsonWeightedAverage`, plus `RungeKutta4`; the `RungeKutta`/`SwiftMath` umbrella names no longer describe the breadth). Candidate names: `Calculus`, `SwiftNumerics`, `Numerics`, `SwiftMath` (already taken internally — confusing), something fresher. **Decide later.** The rename will require updating the GitHub repo name (`github.com:luizmb/RungeKutta.git` → new), every consumer's `Package.swift` (`MultiCompartmentModel`, future consumers), and the SwiftPM dependency cache. Coordinate with the `MultiCompartmentModel → BiokineticModels` rename (below) so consumers swap both at once.

- ⏳ **Break the package down** — once renamed, consider splitting into multiple smaller packages along module boundaries: `Math` (Matrix, VectorState, BidimensionalPoint), `MathOperators` (the `⋅`, `≅`, `±` operators), `Calculus` (Taylor, SimpsonWeightedAverage, Derivative, Fibonacci, Fn), `RungeKutta` (RungeKutta4 + Trajectory). Lets consumers pull only what they need (the dosimetry package currently drags the whole umbrella in for Matrix + Taylor + RK4) and lets the FP-duplicate purge happen one package at a time. Trade-off: more `Package.swift` files to maintain.

- ⏳ **`MultiCompartmentModel` → `BiokineticModels`** (consumer-side rename, tracked here because of the joint coordination above) — the dosimetry consumer at `github.com:luizmb/MultiCompartmentModel.git` should be renamed to `BiokineticModels` (or similar) to describe its breadth: it hosts the Compartmental model loader, the Birchall solver, the SolverMethod dispatch, and future dose / SEE calculations. Coordinate the GitHub rename, `Package.swift` `name:` field, target/product names, import paths, and (importantly) the local `.package(path: "../RungeKutta")` line that becomes `.package(url: "https://github.com/luizmb/<new-name>.git", from: "<tagged>")` once Phase B is published.

## New namespace structure (post-2026-05-19)

```
Math/
  Matrix<Scalar: ℝ>            // row-major matrix + +, *, scalar *, apply(to:), with, squared
  VectorState                  // protocol over an ℝ scalar; built-in conformances for [T] and concrete ℝs
  BidimensionalPoint           // existing
  Comparable+/-/Strideable+    // existing
  Log, Numeric+, Symbols       // existing

MathOperators/
  Matrix+Operators             // ⋅ (DOT OPERATOR) for matrix-matrix, scalar-matrix, matrix-vector
  ≅, ±, +/-, √, ^^             // existing

Calculus/
  SimpsonWeightedAverage       // (v1 + 2v2 + 2v3 + v4) / 6 — used by RK4
  Taylor                       // matrix Taylor series of exp (generic building block)
  Derivative, Fibonacci, Fn    // existing

RungeKutta/
  RungeKutta4                  // scalar + vector overloads; both delegate to SimpsonWeightedAverage
  RungeKutta4.trajectory(…)    // one-shot integrator returning [(time, state)]
```

The Birchall algorithm namespace lives in the dosimetry consumer
(`MultiCompartmentModel/Sources/MultiCompartmentModel/Birchall.swift`) because the
algorithm was published specifically for compartmental dosimetry models. Generic
scaling-and-squaring matrix exponentials, when needed, would live here under their
own named namespace.

Algorithm-named static functions live under `enum AlgorithmName { static func … }`. The naming convention is: if a sub-step has a known mathematical / historical name, give it its own namespace (`SimpsonWeightedAverage`, `Taylor`, `Birchall`); otherwise leave as a private helper inside the parent algorithm.

Inline docs are written for non-mathematicians: explain the concept, link to the canonical text (Butcher, Moler–Van Loan, Birchall 1986, Strang, Wikipedia), and walk through the algorithm step by step.

Custom mathematical symbols are welcome (currently `⋅` for multiplication, `√`/`^^` already shipping). The convention is *named function first, operator as ergonomic alias second* — so symbol-shy users always have the long form available.

## Already in FP — delete from RungeKutta

Whole modules are obsolete vs. what FP now ships:

- **`Sources/Monoid/`** — value-struct `Monoid<T>`/`Semigroup<T>` + `HasDefaultMonoid`. FP uses protocol-based `Semigroup`/`Monoid` with named newtypes (`NumericMonoid.Sum/Product/Min/Max`, `Bool.Monoids.And/Or/Xor`, `SIMDMonoid`, `Endo`, `Iso`), plus `mconcat`/`sconcat`. Drop module.
- **`Sources/Morphisms/`** — boxed `Function<I,O>`, `Endomorphism`, n-ary `Function2…7`, Functor/Applicative/Monad/Profunctor instances. Covered by FP's `FunctionWrapper`, `Endo<A>`, `Reader<Env,A>`, free `curry`/`uncurry`/`flip`/`partialApply`/`compose`, parameter-pack `fanout`, and `Function+Functor/Applicative/Monad`. Drop module.
- **`Sources/FoundationCategoryTheory/`** — Monoid instances on Foundation types + Applicative/zip for Array/Optional/Result/Publisher. All present in FP's `*+Semigroup.swift`, `*+Applicative.swift`, plus `Combine/` and `ModernConcurrency/` trees (which add Publisher/AsyncSequence transformers RungeKutta lacks). Drop module.
- **`Sources/FoundationCategoryTheoryOperators/`** — `<*>` / `>>=` / `>=>` per type. Present in FP under a documented precedence ladder (note: FP uses `>>-` not `>>=` to avoid the stdlib bitwise clash). Drop module.
- **`Sources/CompositionOperators/`** — `^` (KeyPath/closure→`Function`), `|>`, `<*>`, `>>=`, `>=>`, `>>>`, `<<<`, `•`, and their precedence groups. All present in FP's `CoreFPOperators`. FP's `^` lifts KeyPath into `Lens` (the better design). Drop module.

## ~~Worth lifting into FP (small, generic)~~ — already in FP; deleted from RK 2026-05-19

All three items are already shipping in FP and were duplicated here:

- ✅ `Comparable.clamped(to:)` / `within(_:)` — FP's `CoreFP/Utilities/Comparable+Clamp.swift`. RK's `Sources/Math/Comparable+Extensions.swift` deleted; `Sources/Math/Numeric+Extensions.swift` imports `CoreFP` now.
- ✅ `Array.cartesian(_:_:…)` 2/3/4-ary tuple version — FP's `CoreFP/Array/Array+Cartesian.swift`. RK's `Sources/Math/Collection+Extensions.swift` deleted.
- ✅ `Strideable.plusMinus(_:)` and the `±` / `+/-` operators — FP ships these directly on `Strideable` in `CoreFPOperators/Utilities/NumericOperators.swift` (the named-function form is `symmetricRange` in `CoreFP/Utilities/NumericOperations.swift`). RK's `Sources/Math/Strideable+Extensions.swift` and `Sources/MathOperators/PlusMinusRange.swift` deleted.
- ✅ `≅` (approximate equality, `base.within(range)`) — FP declares the operator in `CoreFPOperators/Utilities/Operators.swift`. RK's `Sources/MathOperators/ApproximateEquality.swift` deleted.

`Math` target now depends on `CoreFP`; `MathOperators` target now depends on `CoreFPOperators`. Consumers `import CoreFP` (transitively via `Math`) to get `clamped`/`within`/`cartesian`/`symmetricRange`, and `import CoreFPOperators` (transitively via `MathOperators`) for `±`/`+/-`/`≅`.

## Stays in RungeKutta (math/calculus)

- `Sources/RealNumber/` — `ℝ` protocol + Double/Float/Float16/Float80/Decimal conformances. No business in FP.
- `Sources/Math/` — `BidimensionalPoint`, `TridimensionalPoint`, `slope`, `Log/logC`, `Symbols`, `Numeric+Extensions` (linearInterpolation/linearProgress/interpolateProgress/logistic).
- `Sources/MathOperators/` — `^^`, `√`, `∛` (`ℝ`-dependent).
- `Sources/Calculus/` — `DerivativeFunction`, `Fibonacci`, `Fn`.
- `Sources/RungeKutta/` — `RungeKutta4`.
- `Sources/SwiftMath/` — umbrella.

End-state Package.swift: only those six targets, with FP added as a dependency. Inside the math code, `Fn<T> = Endomorphism<T>` becomes `Fn<T> = Endo<T>`; any remaining `Function<A,B>` usages collapse to plain `(A) -> B` or `Reader`/`Endo`.

---

# Bugs & gotchas to fix before the white-paper / MultiCompartmentModel pass

## RungeKutta4 — double-adds y₀

[Sources/RungeKutta/RungeKutta4.swift:28](Sources/RungeKutta/RungeKutta4.swift) returns `pt𝓃.y + (Δy1 + 2Δy2 + 2Δy3 + Δy4)/6` — i.e. the *next y*, not Δy. But [Sources/RungeKutta/RungeKutta4.swift:36](Sources/RungeKutta/RungeKutta4.swift) then computes `BidimensionalPoint(x: lastPoint.x + Δx, y: lastPoint.y + Δy)` — adding `lastPoint.y` a second time. Either `rk4` should drop the leading `pt𝓃.y +` (match the README & old `rungeKutta4`), or `calculateNextPoint` should stop adding `lastPoint.y`. Pick one — easiest to match README and have `rk4` return pure Δy.

Also: `calculateNextPoint`'s `currentPointInTime` parameter is unused — it's only there to fit `reduce`'s shape. Fine, but worth a one-line `_` comment.

## ~~Playground is broken vs. current source~~ — deleted 2026-05-19

The `CalculusPlayground.playground` referenced the old `RungeKuttaPoint` /
`rungeKutta4` / `differentialEquation` / `equationExactSolution` API that was
deleted years ago, and hadn't compiled since. Removed entirely. If interactive
exploration is wanted later, the tests already cover the algorithms end-to-end;
a new playground (or DocC tutorial) can be written against the current API.

## ~~DerivativeFunction — three real issues~~ — fixed 2026-05-19

[Sources/Calculus/Derivative.swift](Sources/Calculus/Derivative.swift):

- ✅ **`fivePoint`**: removed the bogus `fifthPoint` truncation term (which was
  `(h⁴/30)·fn(5)·c₂` — `fn(5)` evaluated the function at literal `5`, not a fourth
  derivative). The canonical 5-point central difference is now what's used.
- ✅ **`isDifferentiable(at:h:)`**: now evaluates the underlying `Fn` at `x-h`,
  `x`, `x+h` and compares one-sided derivative quotients. The tolerance is `√h`
  rather than `h` (smooth functions have `O(h)` truncation error; corners have a
  constant slope jump). Vertical-tangent points like `x^(1/3)` at 0 are also
  detected because Swift's `pow(-h, 1/3)` returns `NaN`, which falls out of the
  `<` comparison as `false`.
- ✅ **`invert()` renamed to `perpendicularSlope()`** (and `perpendicular()`
  updated to call the new name). The old name implied function inversion;
  it actually returns `-1 / self(x)`.

Still open (design choice, not a bug): **`differentiate()` higher-order**
re-applies the same `Method` to the already-derived slope function. Works in
theory; compounds step-size error fast. Worth deciding whether to keep this
convenience or expose explicit higher-order central-difference coefficients
(would need a new `Method` case).

Tests: `testDerivativeNormalPerpendicular` was missing a `.perpendicular()` call
on its slope (the expected values were perpendicular slopes, but the test
computed tangent slopes) — fixed. Removed two test scenarios (`pow(x, 1/3)` at
0, `abs(x)` at 0) that asserted `expectedSlope: 0` at non-differentiable points,
which is mathematically wrong.

## Fibonacci — precision tests already document Quick degrades fast

`testCompareFiboAlgorithmPrecision` accepts `accuracyQuick = 1e7` past index 90 — the Binet-via-`cos` form drifts hard once `n > ~60`. Fine as a curiosity, but don't use `.quick` for anything beyond ~Fib(50). `.precise` is iterative-Double so it caps at exact-representable Fib (~F(78), before `Double` runs out of mantissa). For the white-paper work, if anything similar comes up, prefer `Decimal` or arbitrary precision.

## RungeKuttaTests is a stub

[Tests/RungeKuttaTests/File.swift](Tests/RungeKuttaTests/File.swift) is literally `import Foundation`. There are zero tests for `RungeKutta4.rk4`. The double-add bug above would have been caught by a single rosettacode regression test (`y' = x·√y`, `y(0)=1`, exact `y(x) = (x²+4)²/16`).

---

# Heads-up for MultiCompartmentModel (uranium ingestion / ICRP-style biokinetics)

When you wire RK4 to a multi-compartment model, the current `(BidimensionalPoint<T>) -> T` shape won't fit. Biokinetic compartments are coupled linear ODEs — `dy⃗/dt = A·y⃗ + u⃗(t)` — and you must compute k1…k4 across the *whole state vector at each substep*, not per compartment independently. Per-compartment RK4 with externally-coupled inputs gives the wrong answer; the slope of compartment A at the midpoint depends on compartment B's *midpoint* value, which you only get if you advance them together.

Two reasonable shapes for the generalization:

- **Generic state**: `protocol VectorState { static func + (Self, Self) -> Self; static func * (T, Self) -> Self }` — RK4 becomes `(Time, State) -> State` and the existing `rk4` is the scalar case where `State == T`. Cleanest, lets you keep using `ℝ` for time.
- **Fixed-width with SIMD**: faster, but locks the compartment count at compile time. Probably overkill until profiling says so.

Because ICRP biokinetic systems are linear with constant rate constants, you'll also have an analytic option via matrix exponential `y(t) = exp(A·t)·y₀`. Useful as a ground-truth oracle for RK4 tests — and a faster path when you don't need intermediate trajectories. Worth keeping both in mind once the white paper is in hand.
