//
//  Derivative.swift
//  Calculus
//
//  Created by Luiz Rodrigo Martins Barbosa on 21.03.19.
//  Copyright © 2019 Luiz Rodrigo Martins Barbosa. All rights reserved.
//

import Foundation

public typealias DecimalFn = (Decimal) -> Decimal

public func derivative(h: Decimal = 1e-16, _ f: @escaping DecimalFn) -> DecimalFn {
    return { x in
        (f(x + h) - f(x)) / h
    }
}

public func invert(_ f: @escaping DecimalFn) -> DecimalFn {
    return { x in
        -1 / f(x)
    }
}

public func derivativePerpendicular(h: Decimal = 1e-16, _ f: @escaping DecimalFn) -> DecimalFn {
    return invert(derivative(h: h, f))
}

public func isDifferentiable(at point: Decimal, _ fn: @escaping DecimalFn) -> Bool {
    let limitApproach: Decimal = 1e-16
    let tolerance: Decimal = 1e-15
    let fromLeft = derivative(h: -limitApproach, fn)(point)
    let fromRight = derivative(h: limitApproach, fn)(point)
    return abs(fromLeft - fromRight) < tolerance
}
