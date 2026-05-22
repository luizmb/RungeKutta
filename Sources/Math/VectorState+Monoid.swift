import CoreFP
import RealNumber

// MARK: - Fixed-shape vectors as Monoids

/// `BidimensionalPoint` is a Monoid under elementwise addition with the origin
/// as identity. Composing the witness pattern's runtime flexibility (via
/// ``MonoidWitness``) and the type-level Monoid would force `T` to itself be a
/// Monoid additively — most ``ℝ`` types are, but the static `identity` on
/// `BidimensionalPoint` doesn't need that.
extension BidimensionalPoint where T: Sendable {
    public static var additiveMonoid: MonoidWitness<BidimensionalPoint<T>> {
        MonoidWitness(identity: .zero, combine: +)
    }
}

extension TridimensionalPoint where T: Sendable {
    public static var additiveMonoid: MonoidWitness<TridimensionalPoint<T>> {
        MonoidWitness(identity: .zero, combine: +)
    }
}

// MARK: - Variable-length vectors as Monoids (per-length)

extension Array where Element: ℝ {
    /// Length-parameterised additive monoid over `[Element]`: identity is the
    /// zero vector of the given length, combine is elementwise `+`.
    ///
    /// `[Element]` itself can't conform to ``CoreFP/Monoid`` because the identity
    /// (the all-zeros vector) depends on the length. This factory returns the
    /// witness for a specific length; fold a sequence of equal-length arrays
    /// through it with ``Sequence/reduced(using:)``.
    public static func additiveMonoid(length: Int) -> MonoidWitness<[Element]> {
        MonoidWitness(
            identity: Array(repeating: .zero, count: length),
            combine: +
        )
    }
}
