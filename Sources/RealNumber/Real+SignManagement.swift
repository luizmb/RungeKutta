import Foundation

extension ℝ {
    /// Returns the negated version of itself, meaning the sign is flipped.
    public var negated: Self {
        var copy = self
        copy.negate()
        return copy
    }

    public func useSign(from value: Self) -> Self {
        (value < 0) != (self < 0) ? negated : self
    }
}
