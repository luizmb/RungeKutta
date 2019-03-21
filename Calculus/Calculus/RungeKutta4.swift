//
//  RungeKutta4.swift
//  Calculus
//
//  Created by Luiz Rodrigo Martins Barbosa on 21.03.19.
//  Copyright © 2019 Luiz Rodrigo Martins Barbosa. All rights reserved.
//

import Foundation

public func rungeKutta4(fn: @escaping (/* x: */ Decimal, /* y: */ Decimal) -> /* tangent = Δy / Δx: */ Decimal)
    -> (/* lastPoint pt𝓃: */ RungeKuttaPoint, /* Δx: */ Decimal) -> /* Δy: */ Decimal {
    return { pt𝓃 /* last point (point at beggining of the arc) */, Δx /* time variation */ in

        // Use Euler's method to calculate slope at the beginning (call the differential function)
        // Multiply by Δx to get Δy (slope is the tangent of the curve, therefore Δy / Δx)
        let Δy1 = Δx * fn(pt𝓃.x, pt𝓃.y)

        // Look at the midpoint and calculate the slope there, by using half Δx and half Δy (got by last method)
        // This will offer a more realistic slope, althought biased toward the first half
        let Δy2 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy1 / 2)

        // Look at the midpoint and calculate the slope there, by using half Δx and half Δy (got by last method)
        // This will offer a more realistic slope, althought biased toward the second half because Δy2 is used instead of Δy1
        let Δy3 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy2 / 2)

        // Calculate the slope at the end by using the full Δx and Δy3, which is very biased
        let Δy4 = Δx * fn(pt𝓃.x + Δx, pt𝓃.y + Δy3)

        // Weighted average of 4 Δys, emphasis on midpoint values that are more realistic
        return (Δy1 + 2 * Δy2 + 2 * Δy3 + Δy4) / 6
    }
}
