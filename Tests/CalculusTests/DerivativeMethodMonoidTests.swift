import Calculus
import CoreFP
import Math
import XCTest

final class DerivativeMethodMonoidTests: XCTestCase {
    private let stencil = DerivativeMethod<Double>.CentralStencil.threePoint(order: 1, step: .adaptative)
    private let f = Fn<Double> { x in x * x * x }  // f(x) = x³

    // MARK: - Direct identity / then API

    func testIdentityKeepsFunctionUnchanged() {
        let id = DerivativeMethod<Double>.identity
        XCTAssertEqual(id.deriving(f)(2.0), f(2.0))
    }

    func testIdentityHasOrderZero() {
        XCTAssertEqual(DerivativeMethod<Double>.identity.order, 0)
    }

    func testThenComposesLeftToRightAndAddsOrders() {
        let composed = stencil.then(stencil)
        XCTAssertEqual(composed.order, 2)
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

    func testComposedTwiceApproximatesSecondDerivative() {
        // f(x) = x³, f''(x) = 6x. At x = 2, f''(2) = 12.
        let composed = stencil.then(stencil)
        XCTAssertEqual(
            composed.deriving(f)(2.0),
            12.0,
            accuracy: 1.0,
            "Chained 1st-order stencils lose precision; 1.0 is the documented tolerance band"
        )
    }

    // MARK: - Composition newtype Monoid

    func testCompositionIdentityIsTheIdentityMethod() {
        let id = DerivativeMethod<Double>.Composition.identity
        XCTAssertEqual(id.rawValue.order, 0)
        XCTAssertEqual(id.rawValue.deriving(f)(2.0), f(2.0))
    }

    func testCompositionCombineMatchesThen() {
        let combined = DerivativeMethod<Double>.Composition.combine(
            DerivativeMethod<Double>.Composition(stencil),
            DerivativeMethod<Double>.Composition(stencil)
        )
        XCTAssertEqual(combined.rawValue.order, stencil.then(stencil).order)
        XCTAssertEqual(
            combined.rawValue.deriving(f)(2.0),
            stencil.then(stencil).deriving(f)(2.0),
            accuracy: 1e-12
        )
    }

    func testCompositionMConcatOnEmptyArrayReturnsIdentity() {
        let result: DerivativeMethod<Double>.Composition = mconcat([])
        XCTAssertEqual(result.rawValue.order, 0)
        XCTAssertEqual(result.rawValue.deriving(f)(2.0), f(2.0))
    }

    func testCompositionMConcatChainsStages() {
        let stages = Array(repeating: DerivativeMethod<Double>.Composition(stencil), count: 3)
        let composed: DerivativeMethod<Double>.Composition = mconcat(stages)
        XCTAssertEqual(composed.rawValue.order, 3)
    }

    func testCompositionIsAssociative() {
        let s = DerivativeMethod<Double>.Composition(stencil)
        let lhs = DerivativeMethod<Double>.Composition.combine(
            DerivativeMethod<Double>.Composition.combine(s, s),
            s
        )
        let rhs = DerivativeMethod<Double>.Composition.combine(
            s,
            DerivativeMethod<Double>.Composition.combine(s, s)
        )
        XCTAssertEqual(lhs.rawValue.order, rhs.rawValue.order)
        XCTAssertEqual(
            lhs.rawValue.deriving(f)(2.0),
            rhs.rawValue.deriving(f)(2.0),
            accuracy: 1e-6
        )
    }
}
