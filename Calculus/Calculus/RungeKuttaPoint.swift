//
//  RungeKuttaPoint.swift
//  Calculus
//
//  Created by Luiz Rodrigo Martins Barbosa on 21.03.19.
//  Copyright © 2019 Luiz Rodrigo Martins Barbosa. All rights reserved.
//

import Foundation

public struct RungeKuttaPoint {
    public let x: Decimal
    public let y: Decimal

    public init(x: Decimal, y: Decimal) {
        self.x = x
        self.y = y
    }

    public func error(exactSolution: Decimal) -> Decimal {
        return abs(y - exactSolution)
    }
}

extension RungeKuttaPoint {
    public static func calculateNextPoint(Δx: Decimal, stepCalculator: @escaping (RungeKuttaPoint, Decimal) -> Decimal) -> ([RungeKuttaPoint], Decimal) -> [RungeKuttaPoint] {
        return { points, currentPointInTime in
            let lastPoint = points.last!
            let Δy = stepCalculator(lastPoint, Δx)
            return points + [.init(x: lastPoint.x + Δx,
                                   y: lastPoint.y + Δy)]
        }
    }
}
