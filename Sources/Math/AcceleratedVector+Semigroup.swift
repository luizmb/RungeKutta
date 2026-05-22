import CoreFP

// MARK: - Monoid under concatenation (mirrors Array's direct conformance)
//
// This is the *collection-shaped* monoid on `AcceleratedVector` — `combine` joins two
// vectors end-to-end and `identity` is the empty `AcceleratedVector()`. Same idiom FP
// uses for `Array: Monoid`.
//
// Note this is **distinct from elementwise addition** (`+`, which comes from
// the `VectorState` conformance). Folding via `mconcat` here gives you a
// concatenated buffer, not a per-index sum. If you want the elementwise sum
// (which is size-dependent so needs `Semigroup` rather than `Monoid`), see
// ``AcceleratedVector/Sum`` and fold with `sconcat(_:_:)`.

extension AcceleratedVector: Semigroup {
    public static func combine(_ lhs: AcceleratedVector, _ rhs: AcceleratedVector) -> AcceleratedVector {
        AcceleratedVector(lhs.storage + rhs.storage)
    }
}

extension AcceleratedVector: Monoid {
    public static var identity: AcceleratedVector { AcceleratedVector([]) }
}

// MARK: - Elementwise additive Semigroup (mirrors Matrix.Sum)

extension AcceleratedVector {
    /// `AcceleratedVector` under elementwise addition as a **semigroup** (not a monoid).
    ///
    /// Naming matches FP's `NumericMonoid<T>.Sum` and `Matrix<Scalar>.Sum` —
    /// "Sum" is the established spelling for "elementwise addition under a
    /// wrapper". `Semigroup` rather than `Monoid` because the identity (the
    /// zero vector) depends on length and a `static var identity: Self`
    /// can't carry a runtime parameter. Fold non-empty inputs with
    /// `sconcat(_:_:)`:
    ///
    /// ```swift
    /// import CoreFP
    /// let total = sconcat(
    ///     AcceleratedVector.Sum(vectors[0]),
    ///     vectors.dropFirst().map(AcceleratedVector.Sum.init)
    /// )
    /// total.rawValue   // elementwise sum across the inputs
    /// ```
    ///
    /// All operands must share the same length — `combine` calls the
    /// shape-checked elementwise `+` from `VectorState`.
    public struct Sum: Semigroup, RawRepresentable {
        public let rawValue: AcceleratedVector

        public init(_ rawValue: AcceleratedVector) {
            self.rawValue = rawValue
        }

        public init?(rawValue: AcceleratedVector) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Sum, _ rhs: Sum) -> Sum {
            Sum(lhs.rawValue + rhs.rawValue)
        }
    }
}
