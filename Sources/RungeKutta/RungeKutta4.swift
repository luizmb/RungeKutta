import Calculus
import Foundation
import Math
import RealNumber

/// Classical fourth-order Runge–Kutta method for ordinary differential equations.
///
/// Given a first-order ODE `dy/dx = f(x, y)` and an initial point `(xₙ, yₙ)`, RK4
/// advances by one step `Δx` using four slope samples:
///
/// 1. `k₁ = f(xₙ, yₙ)` — slope at the start of the interval.
/// 2. `k₂ = f(xₙ + Δx/2, yₙ + Δx·k₁/2)` — slope at the midpoint, using Euler from k₁.
/// 3. `k₃ = f(xₙ + Δx/2, yₙ + Δx·k₂/2)` — slope at the midpoint again, using k₂.
/// 4. `k₄ = f(xₙ + Δx, yₙ + Δx·k₃)` — slope at the end, using k₃.
///
/// The new y is then `yₙ + Δx · (k₁ + 2·k₂ + 2·k₃ + k₄) / 6` — a Simpson's-rule
/// weighted average of the four slopes. The weighting is delegated to
/// ``SimpsonWeightedAverage/calculate(_:_:_:_:)`` so the algorithmic concept lives
/// in one place.
///
/// RK4 is *fourth-order accurate*: the local truncation error per step is `O(Δx⁵)`
/// and the global error after integrating from `x₀` to `xₙ` is `O(Δx⁴)`. Halving the
/// step size cuts the error by about 16×.
///
/// References:
/// - Butcher, *Numerical Methods for Ordinary Differential Equations* (Wiley, 2016), §2.4.
/// - Press et al., *Numerical Recipes*, §17.1.
/// - https://en.wikipedia.org/wiki/Runge–Kutta_methods
/// - https://rosettacode.org/wiki/Runge-Kutta_method (the regression case used in the
///   `RungeKutta4ScalarTests.testRosettacode` test).
public enum RungeKutta4 { }

extension RungeKutta4 {
    /// Scalar RK4 step. Returns the function `(point, Δx) → Δy` — pure delta, *not*
    /// `yₙ + Δy`. Wrap with ``calculateNextPoint(Δx:stepCalculator:)`` (or call
    /// `lastPoint.y + Δy` yourself) to advance.
    public static func rk4<T: ℝ & VectorState>(_ fn: @escaping (BidimensionalPoint<T>) -> T)
    -> (/* lastPoint pt𝓃: */ BidimensionalPoint<T>, /* Δx: */ T) -> T where T.Scalar == T {
        { pt𝓃, Δx in
            let Δy1 = Δx * fn(pt𝓃)
            let Δy2 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy1 / 2))
            let Δy3 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy2 / 2))
            let Δy4 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx, y: pt𝓃.y + Δy3))
            return SimpsonWeightedAverage.calculate(Δy1, Δy2, Δy3, Δy4)
        }
    }

    /// `reduce`-shaped helper that appends the next `(x + Δx, y + Δy)` point.
    /// The `currentPointInTime` argument from the reducing sequence is unused —
    /// it's only here so the signature lines up with `reduce`'s `(Accumulator, Element)`.
    public static func calculateNextPoint<T: ℝ>(
        Δx: T,
        stepCalculator: @escaping (BidimensionalPoint<T>, T) -> T
    ) -> ([BidimensionalPoint<T>], T) -> [BidimensionalPoint<T>] {
        { points, _ in
            guard let lastPoint = points.last else { return [] }
            let Δy = stepCalculator(lastPoint, Δx)
            return points + [BidimensionalPoint(x: lastPoint.x + Δx, y: lastPoint.y + Δy)]
        }
    }
}
