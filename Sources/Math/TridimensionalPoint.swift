import Foundation
import RealNumber

public struct TridimensionalPoint<T: ℝ> {
    public let x: T
    public let y: T
    public let z: T

    public init(x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
    }
}
