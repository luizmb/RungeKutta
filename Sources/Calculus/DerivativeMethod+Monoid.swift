import CoreFP
import Math
import RealNumber

extension DerivativeMethod {
    /// The no-op derivative method: returns the input function unchanged, claims
    /// order 0. Identity for left-to-right composition via ``then(_:)``.
    public static var identity: DerivativeMethod<Scalar> {
        DerivativeMethod(order: 0) { $0 }
    }

    /// Compose two methods left-to-right: apply `self` first, then `other` to
    /// the resulting slope function. Orders add.
    ///
    /// **Accuracy caveat**: chaining stencils compounds truncation error — the
    /// composed method's effective accuracy is typically lower than a direct
    /// higher-order method tuned for that order. Prefer
    /// ``CentralStencil/fivePoint(order:step:)`` (etc.) when a direct method exists.
    public func then(_ other: DerivativeMethod<Scalar>) -> DerivativeMethod<Scalar> {
        DerivativeMethod(order: order + other.order) { f in
            other.deriving(self.deriving(f))
        }
    }

    /// `DerivativeMethod` under left-to-right composition as a monoid.
    /// Identity is ``DerivativeMethod/identity``; combine is ``then(_:)``.
    ///
    /// Newtype wrapper following FP's ``NumericMonoid`` pattern, so methods
    /// fold cleanly with ``mconcat(_:)``:
    ///
    /// ```swift
    /// let pipeline = mconcat(stages.map(DerivativeMethod.Composition.init))
    /// let derivative = pipeline.rawValue.deriving(f)
    /// ```
    public struct Composition: Monoid, RawRepresentable {
        public let rawValue: DerivativeMethod<Scalar>

        public init(_ rawValue: DerivativeMethod<Scalar>) {
            self.rawValue = rawValue
        }

        public init?(rawValue: DerivativeMethod<Scalar>) {
            self.init(rawValue)
        }

        public static func combine(_ lhs: Composition, _ rhs: Composition) -> Composition {
            Composition(lhs.rawValue.then(rhs.rawValue))
        }

        public static var identity: Composition {
            Composition(.identity)
        }
    }
}
