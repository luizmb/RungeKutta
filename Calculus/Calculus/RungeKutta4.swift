//
//  RungeKutta4.swift
//  Calculus
//
//  Created by Luiz Rodrigo Martins Barbosa on 21.03.19.
//  Copyright © 2019 Luiz Rodrigo Martins Barbosa. All rights reserved.
//

import Foundation

public func rungeKutta4(fn: @escaping (Decimal, Decimal) -> Decimal) -> (RungeKuttaPoint, Decimal) -> Decimal {
    return { pt𝓃, Δx in
        let Δy1 = Δx * fn(pt𝓃.x, pt𝓃.y)
        let Δy2 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy1 / 2)
        let Δy3 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy2 / 2)
        let Δy4 = Δx * fn(pt𝓃.x + Δx, pt𝓃.y + Δy3)
        return (Δy1 + 2 * Δy2 + 2 * Δy3 + Δy4) / 6
    }
}
