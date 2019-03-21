import Foundation

public func differentialEquation(x: Decimal, y: Decimal) -> Decimal {
    return x * Decimal(sqrt(NSDecimalNumber(decimal: y).doubleValue))
}

public func equationExactSolution(x: Decimal, y: Decimal) -> Decimal {
    return pow(x * x + 4, 2) / 16
}
