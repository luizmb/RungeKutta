# What's left — SwiftCalx + neighbours

Snapshot: 2026-05-21. The original "migration plan" (strip RungeKutta down to math + calculus + RK, point at FP for the plumbing) is complete. This file now tracks the remaining work — package split / consumer coordination — and the deferred design notes.

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
- **Author-named factory rename (2026-05-21, [PR #3](https://github.com/luizmb/RungeKutta/pull/3))**. `centralStencilCustom` → `fornbergCentralStencil`. Removed the hollow `Richardson` enum placeholder; `richardsonExtrapolation` stays flat alongside `custom` and `fornbergCentralStencil`. Codified the convention: namespace when a family has multiple members; flat author-prefixed name otherwise.
- **RungeKutta45 + NormedVectorState (2026-05-21, [PR #4](https://github.com/luizmb/RungeKutta/pull/4))**. Dormand–Prince 5(4) embedded pair with FSAL and PI step-size control. `NormedVectorState: VectorState` adds an `infinityNorm` requirement (needed by adaptive solvers); conformances for `[Element: ℝ]` and the scalar `ℝ` types.
- **Package rename to `SwiftCalx` (2026-05-21)**. `RungeKutta` / `SwiftMath` umbrella names no longer described the breadth (the package now hosts `Math.Matrix`, `Calculus.Taylor`, `Calculus.SimpsonWeightedAverage`, `Calculus.DerivativeMethod`, `RungeKutta4`, `RungeKutta45`, …). New name from Latin *calx* (small stone for reckoning, root of *calculate*) — short, distinctive, not over-committed to "calculus". Library / target / module names (`Math`, `MathOperators`, `Calculus`, `RungeKutta`, `RealNumber`) stay unchanged so consumers' `import Math` etc. don't break.

## Current layout

```
Math/
  Matrix<Scalar: ℝ>            // row-major matrix + +, *, scalar *, apply(to:), with, squared
  VectorState                  // vector-space protocol; built-in conformances for [T: ℝ] and concrete ℝs
  NormedVectorState            // VectorState + infinityNorm; required by adaptive solvers
  BidimensionalPoint, TridimensionalPoint, slope
  Log, Numeric+, Symbols

MathOperators/
  Matrix+Operators             // ⋅ (DOT OPERATOR) for matrix-matrix, scalar-matrix, matrix-vector
  ≅, ±, +/-, √, ^^

Calculus/
  SimpsonWeightedAverage       // (v1 + 2v2 + 2v3 + v4) / 6 — used by RK4
  Taylor                       // matrix Taylor series of exp (generic building block)
  Derivative, DerivativeMethod // witness pattern; CentralStencil / ForwardStencil /
                               // BackwardStencil / Compose namespaces + flat
                               // richardsonExtrapolation / fornbergCentralStencil / custom
  Fibonacci, Fn

RungeKutta/
  RungeKutta4                  // fixed-step; scalar + vector overloads; SimpsonWeightedAverage core
  RungeKutta4.trajectory(…)    // one-shot integrator returning [(time, state)]
  RungeKutta45                 // Dormand–Prince 5(4) embedded pair, FSAL
  RungeKutta45.trajectory(…)   // adaptive driver with PI step-size control

SwiftCalx/
  @_exported.swift             // umbrella product re-exporting Math, MathOperators,
                               // Calculus, RealNumber, RungeKutta
```

Birchall's scaling-and-squaring matrix-exponential lives in the dosimetry consumer (`MultiCompartmentModel/Sources/MultiCompartmentModel/Birchall.swift`) because Birchall 1986 published it specifically for compartmental dosimetry models. The generic building blocks it composes — `Math.Matrix`, `Matrix.squared(times:)`, `Calculus.Taylor.exponential` — stay here. If a non-Birchall scaling-and-squaring variant (Padé, Moler & Van Loan algorithm 11, etc.) is ever needed in pure numerical linear algebra, it lands here under its own namespace.

Conventions:
- **Algorithm-author names where possible.** `Birchall`, `Taylor`, `SimpsonWeightedAverage`, `Richardson`, `Fornberg`, `Fibonacci`, `RungeKutta`, `DormandPrince` (referenced inside `RungeKutta45`) — historical names give consumers immediate recognition and a search term for the literature.
- **Namespace when a family has multiple members; flat name otherwise.** `CentralStencil.threePoint` / `CentralStencil.fivePoint` deserves the nesting because both surface together when typing `CentralStencil.`. A single-method "namespace" hurts more than it helps — it costs an autocomplete tap without grouping anything. So `richardsonExtrapolation(coarse:fine:leadingOrder:)` and `fornbergCentralStencil(points:order:step:)` stay flat alongside `custom(order:deriving:)` rather than living inside hollow `Richardson` / `Fornberg` enums.
- Docs are written for non-mathematicians: explain the concept, link to the canonical text (Butcher, Moler–Van Loan, Birchall 1986, Dormand–Prince 1980, Fornberg 1988, Strang, Wikipedia), walk through the algorithm.
- Custom mathematical symbols are welcome (`⋅`, `√`, `^^` already ship). The convention is *named function first, operator as ergonomic alias second*.

---

## ⏳ Pending

### Tag `2.0.0`
After the rename PR merges, tag `2.0.0` (the package identifier change is a breaking change for consumers — they need to update both the URL and the `from:` version).

### Bump MCM (consumer)
`MultiCompartmentModel` is the only known consumer right now. Replace its `.package(url: "https://github.com/luizmb/RungeKutta.git", from: "1.8.x")` with `.package(url: "https://github.com/luizmb/SwiftCalx.git", from: "2.0.0")` and add a `SolverMethod.rungeKutta45(tolerance:)` case alongside `.birchall` / `.rungeKutta4(stepSize:)`.

### Break the package down
Consider splitting into separate **repositories** along module lines:
- `Math` — Matrix, VectorState, NormedVectorState, BidimensionalPoint, TridimensionalPoint
- `MathOperators` — `⋅`, `≅`, `±`, etc.
- `Calculus` — Taylor, SimpsonWeightedAverage, Derivative, DerivativeMethod, Fibonacci, Fn
- `RungeKutta` — RungeKutta4, RungeKutta45, trajectories
- `SwiftCalx` (umbrella) — re-exports everything for one-line imports

Lets consumers pull only what they need (the dosimetry package currently drags the whole umbrella in for Matrix + Taylor + RK4) and lets future FP-duplicate purges happen one package at a time. Trade-off: more `Package.swift` files to maintain; coordinated versioning becomes harder. **Needs user-side work** — creating new GitHub repos, migrating history, redirecting URLs.

### MCM → BiokineticModels (consumer-side rename)
`MultiCompartmentModel` is misnamed — it hosts the compartmental loader, Birchall solver, `SolverMethod` dispatch, and future dose / SEE calculations. Rename to `BiokineticModels` (or similar) to describe its breadth. Coordinate the GitHub rename, `Package.swift` `name:`, target/product names, import paths, and the `.package(url:)` URL once published.

### Open design choices (not bugs)

- **State shape for biokinetics / multi-compartment.** When wiring RK4 / RK45 into a multi-compartment model, per-compartment integration with externally-coupled inputs gives the wrong answer — coupled linear ODEs `dy⃗/dt = A·y⃗ + u⃗(t)` need all compartments advanced together at every substep. The generic-state shape (`VectorState` / `NormedVectorState`) we shipped is the right answer; a fixed-width SIMD variant is faster but locks the compartment count at compile time. Defer SIMD until profiling demands it. Because ICRP biokinetic systems are linear with constant rate constants, the **analytic** option `y(t) = exp(A·t) · y₀` is also available (shipped via `Birchall` + `Math.Matrix.squared(times:)`); useful as a ground-truth oracle for the RK solvers and a faster path when intermediate trajectories aren't needed.

### Known-and-documented limitations (not TODOs)

- **Fibonacci `.quick`** (the Binet-via-`cos` form) drifts hard once `n > ~60`; `testCompareFiboAlgorithmPrecision` already accepts `accuracyQuick = 1e7` past index 90. Documented as a curiosity; for arbitrary precision, prefer `Decimal` or genuine bignum.

---

## 🔭 Future iterations

Things to keep in mind for future additions to SwiftCalx. None of these are required by any current consumer — they're potential next moves when the need arises.

### ODE solvers

- **Adams-Bashforth-Moulton** (predictor-corrector) — linear multistep method, reuses past derivatives instead of recomputing them. Fixed-step variant ~200 LoC + tests; variable-step adds ~100 more. Good for long-time smooth integrations where step cost matters; not for stiff systems. Bootstrap with RK4 for the first few steps.
- **Implicit RK5 (Radau IIA)** — A-stable, L-stable, B-stable 5th-order implicit Runge-Kutta. Needs a linear solve per step (LU factorisation of `(I − h·A)` for linear ODEs; Newton iteration for non-linear). ~400 LoC + tests. The right tool for genuinely stiff non-linear systems.
- **BDF (Backward Differentiation Formula)** orders 1–6 — the standard for stiff ODEs (variable-order, variable-step). What SciPy's `LSODA` switches to when it detects stiffness. ~500 LoC + tests.
- **Rosenbrock methods** — semi-implicit (no inner Newton iteration; just one linear solve per stage). Cheaper than fully-implicit on moderately stiff problems. ~300 LoC + tests.
- **Dense output / interpolation** for `RungeKutta45` — allow the adaptive integrator to evaluate `y(t)` at arbitrary `t` between accepted steps using a 5th-order interpolant. Useful for fixed-cadence output without re-running the integrator at chosen times.
- **Other explicit RK variants** — Cash-Karp 5(4), Verner's 6(5) / 8(7) — different Butcher tableaux for accuracy/cost tradeoffs.
- **Implicit Euler (BDF1)** — simple first-order implicit method; useful as a baseline / teaching example for the implicit family.

### Quadrature (definite integrals)

- **Simpson's rule** for `∫ₐᵇ f(x) dx` — adaptive Simpson with error estimation.
- **Gauss–Legendre quadrature** — orthogonal-polynomial weights; very high accuracy for smooth integrands.
- **Romberg integration** — Richardson extrapolation applied to trapezoidal rule.
- **Adaptive Gauss-Kronrod** — the de facto standard adaptive quadrature (`qag` in QUADPACK).
- **Multidimensional quadrature** — tensor product of 1D rules; Monte Carlo and quasi-Monte Carlo for high dimensions.

### Root finding

- **Newton's method** — uses the existing `DerivativeFunction` for the slope; natural fit.
- **Bisection** — guaranteed convergence for sign-changing brackets; slow but bulletproof.
- **Secant method** — Newton without the explicit derivative.
- **Brent's method** — combines bisection / secant / inverse quadratic interpolation; the practical default.
- **Multidimensional Newton** — needs the Jacobian (from `DerivativeMethod` extended to vector-valued functions, or finite-difference approximation).

### Optimisation

- **Gradient descent** — fixed step, momentum, Adam, AdaGrad variants.
- **Newton's method for optimisation** — uses Hessian (second-derivative matrix).
- **Conjugate gradient** — for large sparse systems.
- **BFGS / L-BFGS** — quasi-Newton; approximates the Hessian without storing it.
- **Nelder-Mead** — derivative-free; useful when gradient is unavailable.

### Linear algebra

- **LU decomposition** with partial pivoting — `A x = b` solvers; basis for many implicit-solver inner loops.
- **QR decomposition** — least squares, eigenvalue iterations.
- **Cholesky** — symmetric positive-definite systems; twice as fast as LU.
- **Eigenvalues / eigenvectors** — QR algorithm, power iteration, Jacobi rotations.
- **SVD** — Singular Value Decomposition; the swiss-army knife of linear algebra.
- **Sparse matrices** — CSR/CSC storage, sparse `*`, sparse linear solvers.

### Interpolation

- **Cubic spline** (natural, clamped, not-a-knot).
- **Hermite interpolation** — uses derivatives at interpolation points.
- **Lagrange interpolation** — closed form via the Lagrange basis polynomials.
- **Barycentric Lagrange** — numerically stable evaluation.

### Special functions

- **Gamma, log-gamma, digamma, beta** — needed for statistics, combinatorics.
- **Erf, erfc, inverse erf** — for normal-distribution CDF/PPF.
- **Bessel functions** — wave physics, signal processing.

### Polynomial operations

- **Horner evaluation** — numerically stable.
- **Roots of polynomials** — companion matrix eigenvalues, or specialised cubic / quartic.
- **Least squares polynomial fit** — Vandermonde + QR.

### FFT

- **Discrete Fourier Transform** and inverse — Cooley-Tukey radix-2 / mixed radix.
- **Real-input FFT** — half the storage / half the work for real signals.
- **Convolution** via FFT.

### Random sampling

- **Distributions** — uniform, normal, exponential, gamma, beta, Poisson, binomial.
- **Quasi-random sequences** — Sobol, Halton for low-discrepancy sampling.
- **Monte Carlo integration** — using the above + variance reduction techniques.

### Decision rule for adding any of the above

We don't add things speculatively. Each addition needs **either** (a) a concrete consumer use case that would otherwise have to roll its own, or (b) a clear conceptual gap whose absence makes the library feel incomplete to its target audience. The author-name convention applies — `Newton`, `Gauss`, `Simpson`, `Cooley-Tukey`, etc. — and the namespace-vs-flat rule applies.
