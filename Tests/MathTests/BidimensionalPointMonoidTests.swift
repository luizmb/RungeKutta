import CoreFP
import Math
import XCTest

final class BidimensionalPointMonoidTests: XCTestCase {
    typealias P = BidimensionalPoint<Double>

    func testIdentityIsTheOrigin() {
        XCTAssertEqual(P.Additive.identity.rawValue, P(x: 0, y: 0))
    }

    func testLeftIdentityReturnsValue() {
        let p = P.Additive(P(x: 3, y: -2.5))
        XCTAssertEqual(P.Additive.combine(.identity, p).rawValue, p.rawValue)
    }

    func testRightIdentityReturnsValue() {
        let p = P.Additive(P(x: 3, y: -2.5))
        XCTAssertEqual(P.Additive.combine(p, .identity).rawValue, p.rawValue)
    }

    func testCombineMatchesElementwiseAddition() {
        let lhs = P.Additive(P(x: 1, y: 2))
        let rhs = P.Additive(P(x: 4, y: -3))
        XCTAssertEqual(P.Additive.combine(lhs, rhs).rawValue, P(x: 5, y: -1))
    }

    func testAssociativity() {
        let a = P.Additive(P(x: 1, y: 2))
        let b = P.Additive(P(x: 3, y: 4))
        let c = P.Additive(P(x: 5, y: 6))
        XCTAssertEqual(
            P.Additive.combine(P.Additive.combine(a, b), c).rawValue,
            P.Additive.combine(a, P.Additive.combine(b, c)).rawValue
        )
    }

    func testMConcatOnEmptyArrayReturnsIdentity() {
        let result: P.Additive = mconcat([])
        XCTAssertEqual(result.rawValue, .zero)
    }

    func testMConcatFoldsSequenceThroughCombine() {
        let result: P.Additive = mconcat([
            P.Additive(P(x: 1, y: 2)),
            P.Additive(P(x: 3, y: 4)),
            P.Additive(P(x: 5, y: 6))
        ])
        XCTAssertEqual(result.rawValue, P(x: 9, y: 12))
    }
}
