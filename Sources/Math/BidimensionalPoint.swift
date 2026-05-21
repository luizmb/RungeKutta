import Foundation
import RealNumber

public struct BidimensionalPoint<T: ℝ>: Sendable {
    public let x: T
    public let y: T

    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }

    public func slope(to another: BidimensionalPoint) -> T {
        Math.slope(point: self, anotherPoint: another)
    }
}

public func slope<T: ℝ>(point: BidimensionalPoint<T>, anotherPoint: BidimensionalPoint<T>) -> T {
    guard point.x != anotherPoint.x else { return .zero }
    let leftMost = point.x < anotherPoint.x ? point : anotherPoint
    let rightMost = point.x > anotherPoint.x ? point : anotherPoint
    let Δx = rightMost.x - leftMost.x
    let Δy = rightMost.y - leftMost.y

    return Δy / Δx
}
