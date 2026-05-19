import Foundation
import RealNumber
import Math

public enum RungeKutta4 { }

extension RungeKutta4 {
    public static func rk4<T: ℝ>(_ fn: @escaping (BidimensionalPoint<T>) -> T /* tangent = Δy / Δx: */ )
    -> (/* lastPoint pt𝓃: */ BidimensionalPoint<T>, /* Δx: */ T) -> /* Δy: */ T {
        { pt𝓃 /* last point (point at beggining of the arc) */, Δx /* time variation */ in

            // Slope at the start of the interval. Multiply by Δx to get Δy contribution.
            let Δy1 = Δx * fn(pt𝓃)

            // Slope at the midpoint, biased toward the first half (uses Δy1).
            let Δy2 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy1 / 2))

            // Slope at the midpoint, biased toward the second half (uses Δy2).
            let Δy3 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy2 / 2))

            // Slope at the end of the interval (uses Δy3).
            let Δy4 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx, y: pt𝓃.y + Δy3))

            // Simpson-weighted average of the four slope×Δx contributions = pure Δy.
            // Caller (e.g. `calculateNextPoint`) adds `pt𝓃.y + Δy` to obtain y_{n+1}.
            return (Δy1 + 2 * Δy2 + 2 * Δy3 + Δy4) / 6
        }
    }

    public static func calculateNextPoint<T: ℝ>(Δx: T, stepCalculator: @escaping (BidimensionalPoint<T>, T) -> T) -> ([BidimensionalPoint<T>], T) -> [BidimensionalPoint<T>] {
        { points, currentPointInTime in
            guard let lastPoint = points.last else { return [] }
            let Δy = stepCalculator(lastPoint, Δx)
            return points + [BidimensionalPoint(x: lastPoint.x + Δx, y: lastPoint.y + Δy)]
        }
    }
}
