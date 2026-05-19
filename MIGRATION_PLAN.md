# RungeKutta → FP migration plan & next-steps notes

Snapshot: 2026-05-19. RungeKutta has 11 source modules; FP (`~/code/FP`) now supersedes the FP/category-theory subset. Goal: strip RungeKutta down to math + calculus + RK, pointing at FP for the plumbing.

## Status

- ✅ **Phase B (2026-05-18)** — fixed the `rk4` double-add bug; added `VectorState` protocol + vector-state `rk4` overload; replaced the empty `RungeKuttaTests` stub with 11 real scalar + vector tests.
- ✅ **Math + algorithm namespaces (2026-05-19)** — added `Matrix<T: ℝ>` value type with `+`, `*`, scalar `*`, `apply(to:)`, `with(row:column:value:)`, `squared(times:)`; the `⋅` (DOT OPERATOR) operator wraps `*` / `apply(to:)`; extracted `SimpsonWeightedAverage` (used by both scalar and vector RK4), `Taylor`, and `Birchall` algorithm namespaces under `Calculus/`. Renamed nothing in the public RK4 API.
- ⏳ **FP-duplicate removal** — pending. See the "Already in FP" section below; needs to actually be deleted now that FP is mature. Tracking explicitly:
   - Delete `Sources/Monoid/`, `Sources/Morphisms/`, `Sources/FoundationCategoryTheory/`, `Sources/FoundationCategoryTheoryOperators/`, `Sources/CompositionOperators/`.
   - Add FP (`https://github.com/luizmb/FP`) as a SwiftPM dependency in `Package.swift`.
   - Update remaining targets (`Calculus`, `RungeKutta`, `Math`, `MathOperators`, `SwiftMath`) to import `CoreFP` / `CoreFPOperators` / `DataStructure` where they previously imported the removed local modules.
   - Inside `Sources/Calculus/Fn.swift`, replace `Fn<T> = Endomorphism<T>` with `Fn<T> = Endo<T>` (or just inline `Endo<T>`) and delete the file if it adds no value.
   - Bump the package name from `SwiftMath` (yes, the manifest already uses `SwiftMath`) to something honest like `RungeKutta` — or leave the rename for the broader renaming pass (see below).
- ⏳ **Library rename** — eventually rename the whole package (something broader than `RungeKutta`/`SwiftMath` — the namespaces now include `Math.Matrix`, `Calculus.Birchall`, `Calculus.Taylor`, `Calculus.SimpsonWeightedAverage`, plus `RungeKutta4`). Open question.

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
  Taylor                       // matrix Taylor series of exp
  Birchall                     // scaling-and-squaring matrix exponential
  Derivative, Fibonacci, Fn    // existing

RungeKutta/
  RungeKutta4                  // scalar + vector overloads; both delegate to SimpsonWeightedAverage
```

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

## Worth lifting into FP (small, generic)

Three items are not yet in FP and are general-purpose, not math:

1. `Comparable.clamped(to:)` and `Comparable.within(_:)` — [Sources/Math/Comparable+Extensions.swift](Sources/Math/Comparable+Extensions.swift). Suggest landing as `CoreFP/Utilities/Comparable+Clamp.swift`.
2. `Array.cartesian(_:_:…)` n-ary tuple version — [Sources/Math/Collection+Extensions.swift](Sources/Math/Collection+Extensions.swift). FP's list-applicative `liftA2` covers two-array element-cartesian; the tuple-returning n-ary form is distinct and worth keeping. Rewrite with variadic packs in `CoreFP/Array/`.
3. `Strideable.plusMinus(_:)` — backs the `±`/`+/-` operators which FP already *declares* in `Operators.swift` but with only `SignedNumeric` overloads (`symmetricRange`). Either add a `Strideable` overload or reconcile to one definition.

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

## Playground is broken vs. current source

[CalculusPlayground.playground/Pages/Runge-Kutta 4th order.xcplaygroundpage/Contents.swift](CalculusPlayground.playground/Pages/Runge-Kutta%204th%20order.xcplaygroundpage/Contents.swift) and `Sources/Helpers.swift` still reference the old API (`RungeKuttaPoint`, `rungeKutta4`, `differentialEquation`, `equationExactSolution`) that was deleted along with the old `Calculus/Calculus.xcodeproj/`. The `git status` confirms these files are still around but won't compile against current `Sources/RungeKutta/`. Either resurrect the helpers with the new `BidimensionalPoint`-based API or delete the playground.

## DerivativeFunction — three real issues

[Sources/Calculus/Derivative.swift](Sources/Calculus/Derivative.swift):

- **`fivePoint` is broken** (line 66): `let fifthPoint = (h.raisedToThePower(of: 4) / 30) * fn(5) * c2`. `fn(5)` is "evaluate the function at literal 5", not the 4th-derivative truncation term. The whole `fifthPoint` addition is wrong — the canonical 5-point central difference is just `(-f(x+2h) + 8f(x+h) - 8f(x-h) + f(x-2h)) / (12h)` with no error-term added to the value. Remove the `fifthPoint` term.
- **`isDifferentiable(at:h:)` always returns true near zero** (line 110-113): both `fromLeft` and `fromRight` are bound to `self(x: x)` — the same exact expression. It needs to evaluate the *underlying* `Fn` at `x-h` and `x+h` and compare their slopes (or the function values), not the derivative twice at the same point. The TODO about vertical-tangent detection is downstream of this.
- **`differentiate()` higher-order is structurally suspect**: `slopeFunction` for `.higherOrder(derivative)` re-applies the same `Method` to the *already-derived* `slopeFunction`. Mathematically that's `f'' ≈ D[D[f]]`, which works in theory but compounds the step-size error fast (O(h) for forward, O(h²) for central — squared once you nest). It's fine if you only want a quick `f''`, but doesn't match how the white papers would describe higher-order central differences. Worth deciding whether to keep this convenience or expose explicit higher-order coefficients.

Naming nit: `invert()` on [Sources/Calculus/Derivative.swift:136](Sources/Calculus/Derivative.swift) returns `-1/self(x)` — that's the *perpendicular slope*, not function inversion. Rename to `perpendicularSlope()` / fold into the existing `perpendicular()`.

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
