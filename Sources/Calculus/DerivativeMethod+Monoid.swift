import CoreFP
import Math
import RealNumber

extension DerivativeMethod {
    /// The no-op derivative: returns the input function unchanged, claims order 0.
    ///
    /// Identity for composition: `identity.then(D) == D == D.then(identity)`.
    public static var identity: Self {
        Self(order: 0) { $0 }
    }

    /// Compose two methods left-to-right: apply `self` first, then `other` to the
    /// resulting slope function. Orders add (`self.order + other.order`).
    ///
    /// This is the natural Semigroup operation on numerical-differentiation
    /// methods: chaining a 2nd-derivative method *after* a 1st-derivative method
    /// produces a 3rd-derivative method. Combined with ``identity`` it forms a
    /// monoid.
    ///
    /// **Accuracy caveat**: chaining stencils compounds truncation error — the
    /// composed method's effective accuracy is typically lower than a direct
    /// higher-order method tuned for that order. Prefer
    /// ``CentralStencil/fivePoint(order:step:)`` (etc.) when a direct method exists.
    public func then(_ other: DerivativeMethod) -> DerivativeMethod {
        DerivativeMethod(order: order + other.order) { f in
            other.deriving(self.deriving(f))
        }
    }
}

/// Builds a ``MonoidWitness`` for `DerivativeMethod<Scalar>` under composition.
///
/// `DerivativeMethod` can't conform to ``CoreFP/Monoid`` directly: protocol
/// witnesses need `static var identity: Self`, which closes over no `Scalar`
/// information. The generic factory below produces a witness for any
/// concrete `Scalar: ℝ`.
public func derivativeCompositionMonoid<Scalar: ℝ>(
    over _: Scalar.Type = Scalar.self
) -> MonoidWitness<DerivativeMethod<Scalar>> {
    MonoidWitness(identity: .identity) { lhs, rhs in lhs.then(rhs) }
}
