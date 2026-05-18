import Foundation
import RealNumber
import Math

public enum RungeKutta4 { }

extension RungeKutta4 {
    public static func rk4<T: ℝ>(_ fn: @escaping (BidimensionalPoint<T>) -> T /* tangent = Δy / Δx: */ )
    -> (/* lastPoint pt𝓃: */ BidimensionalPoint<T>, /* Δx: */ T) -> /* Δy: */ T {
        { pt𝓃 /* last point (point at beggining of the arc) */, Δx /* time variation */ in

            // Use Euler's method to calculate slope at the beginning (call the differential function)
            // Multiply by Δx to get Δy (slope is the tangent of the curve, therefore Δy / Δx)
            let Δy1 = Δx * fn(pt𝓃)

            // Look at the midpoint and calculate the slope there, by using half Δx and half Δy (got by last method)
            // This will offer a more realistic slope, althought biased toward the first half
            let Δy2 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy1 / 2))

            // Look at the midpoint and calculate the slope there, by using half Δx and half Δy (got by last method)
            // This will offer a more realistic slope, althought biased toward the second half because Δy2 is used instead of Δy1
            let Δy3 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx / 2, y: pt𝓃.y + Δy2 / 2))

            // Calculate the slope at the end by using the full Δx and Δy3, which is very biased
            let Δy4 = Δx * fn(BidimensionalPoint(x: pt𝓃.x + Δx, y: pt𝓃.y + Δy3))

            // Weighted average of 4 Δys, emphasis on midpoint values that are more realistic, add the initial Y
            return pt𝓃.y + (Δy1 + 2 * Δy2 + 2 * Δy3 + Δy4) / 6
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
