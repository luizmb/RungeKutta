import CoreFP
import RealNumber

extension TridimensionalPoint {
    /// `TridimensionalPoint` as a monoid under elementwise addition. Identity is
    /// the origin `(0, 0, 0)`; combine adds component-wise.
    ///
    /// Mirrors ``BidimensionalPoint/Additive`` and FP's ``NumericMonoid`` newtype
    /// wrappers. Pass values to ``mconcat(_:)`` / ``sconcat(_:_:)`` after wrapping.
    public struct Additive: Monoid, RawRepresentable {
        public let rawValue: TridimensionalPoint<T>

        public init(_ rawValue: TridimensionalPoint<T>) {
            self.rawValue = rawValue
        }

        public init?(rawValue: TridimensionalPoint<T>) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Additive, _ rhs: Additive) -> Additive {
            Additive(lhs.rawValue + rhs.rawValue)
        }

        public static var identity: Additive { Additive(.zero) }
    }
}
