import Calculus
import CoreFP
import Math
import XCTest

final class DerivativeMethodMonoidTests: XCTestCase {
    private let stencil = DerivativeMethod<Double>.CentralStencil.threePoint(order: 1, step: .adaptative)
    private let f = Fn<Double> { x in x * x * x }  // f(x) = x³

    func testIdentityKeepsFunctionUnchanged() {
        let id = DerivativeMethod<Double>.identity
        let result = id.deriving(f)(2.0)
        XCTAssertEqual(result, f(2.0))
    }

    func testIdentityHasOrderZero() {
        XCTAssertEqual(DerivativeMethod<Double>.identity.order, 0)
    }

    func testThenLeftIdentityActsLikeRhs() {
        let composed = DerivativeMethod<Double>.identity.then(stencil)
        XCTAssertEqual(composed.order, stencil.order)
        XCTAssertEqual(composed.deriving(f)(2.0), stencil.deriving(f)(2.0), accuracy: 1e-9)
    }

    func testThenRightIdentityActsLikeLhs() {
        let composed = stencil.then(.identity)
        XCTAssertEqual(composed.order, stencil.order)
        XCTAssertEqual(composed.deriving(f)(2.0), stencil.deriving(f)(2.0), accuracy: 1e-9)
    }

    func testOrdersAddOnComposition() {
        let first = DerivativeMethod<Double>.CentralStencil.threePoint(order: 1, step: .adaptative)
        let second = DerivativeMethod<Double>.CentralStencil.threePoint(order: 1, step: .adaptative)
        XCTAssertEqual(first.then(second).order, 2)
    }

    func testComposedTwiceApproximatesSecondDerivative() {
        // f(x) = x³, f''(x) = 6x. At x = 2, f''(2) = 12.
        let composed = stencil.then(stencil)
        let approx = composed.deriving(f)(2.0)
        XCTAssertEqual(
            approx,
            12.0,
            accuracy: 1.0,
            "Chained 1st-order stencils lose precision; 1.0 is the documented tolerance band"
        )
    }

    func testCompositionIsAssociative() {
        let s = stencil
        let lhs = s.then(s).then(s)
        let rhs = s.then(s.then(s))
        XCTAssertEqual(lhs.order, rhs.order)
        XCTAssertEqual(lhs.deriving(f)(2.0), rhs.deriving(f)(2.0), accuracy: 1e-6)
    }

    func testWitnessIdentityEqualsStaticIdentity() {
        let witness = derivativeCompositionMonoid(over: Double.self)
        XCTAssertEqual(witness.identity.order, DerivativeMethod<Double>.identity.order)
    }

    func testWitnessCombineMatchesThen() {
        let witness = derivativeCompositionMonoid(over: Double.self)
        let combined = witness.combine(stencil, stencil)
        XCTAssertEqual(combined.order, stencil.then(stencil).order)
        XCTAssertEqual(combined.deriving(f)(2.0), stencil.then(stencil).deriving(f)(2.0), accuracy: 1e-12)
    }
}
