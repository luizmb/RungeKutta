import Foundation
import Calculus

public func isWhole(tolerance: Decimal) -> (Decimal) -> Bool {
    return { t in
        abs(t - Decimal(round(NSDecimalNumber(decimal: t).doubleValue))) < tolerance
    }
}
public let wholeTolerance: Decimal = 1e-10
public let shouldPrint: (RungeKuttaPoint) -> Bool = { isWhole(tolerance: wholeTolerance)($0.x) }
public let printPoint: (RungeKuttaPoint) -> Void = { print("f(x: \($0.x))  \t= \($0.y) +/- \($0.error(exactSolution: equationExactSolution(x: $0.x, y: $0.y)))") }
