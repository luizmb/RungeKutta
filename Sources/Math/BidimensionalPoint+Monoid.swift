import CoreFP
import RealNumber

extension BidimensionalPoint {
    /// `BidimensionalPoint` as a monoid under elementwise addition. Identity is
    /// the origin `(0, 0)`; combine adds component-wise.
    ///
    /// Follows the same newtype-wrapper pattern that FP uses for ``NumericMonoid``
    /// (`Sum`, `Product`, `Min`, `Max`). Pass values to ``mconcat(_:)`` /
    /// ``sconcat(_:_:)`` after wrapping them.
    ///
    /// ```swift
    /// let centroid: BidimensionalPoint<Double>.Additive = mconcat(
    ///     points.map(BidimensionalPoint.Additive.init)
    /// )
    /// ```
    public struct Additive: Monoid, RawRepresentable {
        public let rawValue: BidimensionalPoint<T>

        public init(_ rawValue: BidimensionalPoint<T>) {
            self.rawValue = rawValue
        }

        public init?(rawValue: BidimensionalPoint<T>) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Additive, _ rhs: Additive) -> Additive {
            Additive(lhs.rawValue + rhs.rawValue)
        }

        public static var identity: Additive { Additive(.zero) }
    }
}
