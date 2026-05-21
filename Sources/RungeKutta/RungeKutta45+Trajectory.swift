import Foundation
import Math
import RealNumber

extension RungeKutta45 {
    /// Adaptive-step integration of `dy/dt = f(t, y)` from `t = startingAt` to
    /// `t = through`, using Dormand–Prince 5(4) with PI step-size control.
    ///
    /// The integrator keeps the local truncation error of each step near
    /// `tolerance` (an infinity-norm bound on `y5 − y4`). Steps with error
    /// above tolerance are rejected and retried at a smaller step; steps well
    /// inside it grow the next step. A common practical setup is
    /// `tolerance = 1e-6` for double-precision work.
    ///
    /// Returned `(time, state)` pairs are at the **adaptive** time grid the
    /// integrator chose — not uniformly spaced. The first element is
    /// `(startingAt, initialState)` and the last is `(through, finalState)`
    /// (the final step is shrunk to land exactly on `through`).
    ///
    /// For uniform-cadence sampling, post-process: interpolate between
    /// adjacent pairs, or run RK45 stage-by-stage with a fixed output cadence.
    ///
    /// - Parameters:
    ///   - initialState: `y(startingAt)`.
    ///   - derivative: `f(t, y)`. Required `@Sendable`.
    ///   - startingAt: `t₀` — the initial time. Defaults to `0`.
    ///   - through: `t₁` — the final time. Must be `> startingAt`.
    ///   - tolerance: target infinity-norm of `y5 − y4` per step.
    ///   - initialStep: starting `h`. Defaults to `(through − startingAt) / 100`.
    ///   - minStep: smallest step the integrator will try before bailing. `nil`
    ///     (default) lets steps shrink without a floor (useful for diagnosing
    ///     stiffness — the trajectory will just hit `maxIterations`). Set this
    ///     to bail early if stability matters more than completeness.
    ///   - maxStep: largest step the integrator will take. `nil` (default)
    ///     caps at `through − startingAt`.
    ///   - maxIterations: safety bound on total accepted + rejected steps,
    ///     to keep stiffness or pathological inputs from infinite-looping.
    public static func trajectory<State: NormedVectorState>(
        from initialState: State,
        derivative: @escaping @Sendable (Double, State) -> State,
        startingAt t0: Double = 0,
        through t1: Double,
        tolerance: Double = 1e-6,
        initialStep: Double? = nil,
        minStep: Double? = nil,
        maxStep: Double? = nil,
        maxIterations: Int = 10_000
    ) -> [(time: Double, state: State)] where State.Scalar == Double {
        guard t1 > t0 else { return [(time: t0, state: initialState)] }

        let totalSpan = t1 - t0
        var h = initialStep ?? totalSpan / 100
        let hCap = maxStep ?? totalSpan
        let hFloor = minStep ?? 0

        var t = t0
        var y = initialState
        var k1 = derivative(t, y)
        var trajectory: [(time: Double, state: State)] = [(time: t0, state: initialState)]
        var iterations = 0

        while t < t1, iterations < maxIterations {
            iterations += 1

            // Shrink the final step to land exactly on `through`.
            let hStep = min(h, t1 - t)
            let attempt = step(from: t, y: y, k1: k1, size: hStep, derivative: derivative)

            if attempt.errorNorm <= tolerance {
                // Accept: advance, record, reuse k7 as next k1 (FSAL).
                t += hStep
                y = attempt.y5
                k1 = attempt.kLast
                trajectory.append((time: t, state: y))

                // Grow the step for next iteration based on how much
                // headroom we had. The classical PI factor is
                // `0.9 * (tolerance / error)^(1/5)`, clamped to [0.1, 5].
                let factor = stepSizeFactor(errorNorm: attempt.errorNorm, tolerance: tolerance)
                h = min(hCap, max(hFloor, h * factor))
            } else {
                // Reject: shrink h and retry. Same factor formula, but the
                // shrink will be < 1 since error > tolerance.
                let factor = stepSizeFactor(errorNorm: attempt.errorNorm, tolerance: tolerance)
                let newH = max(hFloor, h * factor)
                if newH <= hFloor, h <= hFloor {
                    // Can't shrink further. Bail with what we have.
                    return trajectory
                }
                h = newH
            }
        }

        return trajectory
    }

    /// Standard adaptive-step controller: shrink/grow `h` by
    /// `0.9 * (tolerance / error)^(1/5)`, clamped to `[0.1, 5]` so a single
    /// rough step can't cut `h` by orders of magnitude or grow it past the
    /// next problematic region.
    ///
    /// The `0.9` safety factor keeps the next attempt comfortably below the
    /// tolerance threshold; the `^(1/5)` exponent matches the 5th-order
    /// accuracy of the method (a step `h/2` reduces error by `(1/2)^5`).
    private static func stepSizeFactor(errorNorm: Double, tolerance: Double) -> Double {
        guard errorNorm > 0 else { return 5.0 }
        let raw = 0.9 * pow(tolerance / errorNorm, 0.2)
        return min(5.0, max(0.1, raw))
    }
}
