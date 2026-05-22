import CoreFP
import RealNumber

extension Matrix {
    /// `Matrix` under elementwise addition as a **semigroup** (not a monoid).
    ///
    /// `Semigroup` rather than `Monoid` because the identity (the zero matrix)
    /// depends on the matrix shape — `Monoid.identity` is a `static var Self`
    /// that has no way to pick `rows` or `columns`. ``sconcat(_:_:)`` handles
    /// non-empty folds without needing an identity:
    ///
    /// ```swift
    /// let total = sconcat(Matrix.Additive(matrices[0]), matrices.dropFirst().map(Matrix.Additive.init))
    /// total.rawValue   // matrix sum
    /// ```
    ///
    /// All operands in a fold must share the same shape — `combine` calls the
    /// shape-checked elementwise `+` underneath.
    public struct Additive: Semigroup, RawRepresentable {
        public let rawValue: Matrix<Scalar>

        public init(_ rawValue: Matrix<Scalar>) {
            self.rawValue = rawValue
        }

        public init?(rawValue: Matrix<Scalar>) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Additive, _ rhs: Additive) -> Additive {
            Additive(lhs.rawValue + rhs.rawValue)
        }
    }

    /// `Matrix` under matrix multiplication as a **semigroup** (not a monoid).
    ///
    /// `Semigroup` rather than `Monoid` because the multiplicative identity is
    /// the `n × n` identity matrix `Iₙ` — again, `static var identity` can't
    /// pick a size. The semigroup is also restricted to **square** matrices:
    /// the elementwise product is not closed under arbitrary rectangular
    /// shapes the way addition is.
    ///
    /// This is the algebraic structure behind Birchall's matrix-exponential
    /// semigroup: `exp((s + t) · A) = exp(s · A) · exp(t · A)`. For the
    /// *iterated-action* form used in practice (apply `B = exp(Δt · A)` to a
    /// starting vector `n` times), see ``Matrix/actions(on:count:)`` — it
    /// avoids the O(n³) per step cost of multiplying matrix powers and just
    /// does O(n²) per step mat-vec.
    public struct Multiplicative: Semigroup, RawRepresentable {
        public let rawValue: Matrix<Scalar>

        public init(_ rawValue: Matrix<Scalar>) {
            self.rawValue = rawValue
        }

        public init?(rawValue: Matrix<Scalar>) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Multiplicative, _ rhs: Multiplicative) -> Multiplicative {
            Multiplicative(lhs.rawValue * rhs.rawValue)
        }
    }
}
