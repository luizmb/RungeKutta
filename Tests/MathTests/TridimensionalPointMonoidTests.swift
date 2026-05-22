import CoreFP
import Math
import XCTest

final class TridimensionalPointMonoidTests: XCTestCase {
    typealias P = TridimensionalPoint<Double>

    func testIdentityIsTheOrigin() {
        XCTAssertEqual(P.Additive.identity.rawValue, P(x: 0, y: 0, z: 0))
    }

    func testCombineMatchesElementwiseAddition() {
        let lhs = P.Additive(P(x: 1, y: 2, z: 3))
        let rhs = P.Additive(P(x: 4, y: 5, z: 6))
        XCTAssertEqual(P.Additive.combine(lhs, rhs).rawValue, P(x: 5, y: 7, z: 9))
    }

    func testMConcatFoldsSequence() {
        let result: P.Additive = mconcat([
            P.Additive(P(x: 1, y: 2, z: 3)),
            P.Additive(P(x: 4, y: 5, z: 6)),
            P.Additive(P(x: 7, y: 8, z: 9))
        ])
        XCTAssertEqual(result.rawValue, P(x: 12, y: 15, z: 18))
    }
}
