import Math
import XCTest

final class VectorStateMonoidTests: XCTestCase {
    // MARK: - BidimensionalPoint

    func testBidimensionalAdditiveMonoidIdentityIsOrigin() {
        let witness = BidimensionalPoint<Double>.additiveMonoid
        XCTAssertEqual(witness.identity, .zero)
        XCTAssertEqual(witness.identity, BidimensionalPoint(x: 0, y: 0))
    }

    func testBidimensionalIdentityIsLeftAndRightIdentity() {
        let witness = BidimensionalPoint<Double>.additiveMonoid
        let point = BidimensionalPoint(x: 3.0, y: -2.5)
        XCTAssertEqual(witness.combine(witness.identity, point), point)
        XCTAssertEqual(witness.combine(point, witness.identity), point)
    }

    func testBidimensionalCombineMatchesElementwiseAddition() {
        let lhs = BidimensionalPoint(x: 1.0, y: 2.0)
        let rhs = BidimensionalPoint(x: 4.0, y: -3.0)
        let witness = BidimensionalPoint<Double>.additiveMonoid
        XCTAssertEqual(witness.combine(lhs, rhs), BidimensionalPoint(x: 5.0, y: -1.0))
    }

    func testBidimensionalReducedAcrossSequence() {
        let witness = BidimensionalPoint<Double>.additiveMonoid
        let points = [
            BidimensionalPoint(x: 1.0, y: 2.0),
            BidimensionalPoint(x: 3.0, y: 4.0),
            BidimensionalPoint(x: 5.0, y: 6.0)
        ]
        XCTAssertEqual(points.reduced(using: witness), BidimensionalPoint(x: 9.0, y: 12.0))
    }

    // MARK: - TridimensionalPoint

    func testTridimensionalAdditiveMonoidIdentityIsOrigin() {
        let witness = TridimensionalPoint<Double>.additiveMonoid
        XCTAssertEqual(witness.identity, TridimensionalPoint(x: 0, y: 0, z: 0))
    }

    func testTridimensionalCombineMatchesElementwiseAddition() {
        let witness = TridimensionalPoint<Double>.additiveMonoid
        let lhs = TridimensionalPoint(x: 1.0, y: 2.0, z: 3.0)
        let rhs = TridimensionalPoint(x: 4.0, y: 5.0, z: 6.0)
        XCTAssertEqual(witness.combine(lhs, rhs), TridimensionalPoint(x: 5.0, y: 7.0, z: 9.0))
    }

    // MARK: - Array<ℝ>

    func testArrayAdditiveMonoidIdentityIsZeroVectorOfRequestedLength() {
        let witness = [Double].additiveMonoid(length: 4)
        XCTAssertEqual(witness.identity, [0, 0, 0, 0])
    }

    func testArrayIdentityIsLeftAndRightIdentity() {
        let witness = [Double].additiveMonoid(length: 3)
        let v: [Double] = [1.5, -2.5, 3.5]
        XCTAssertEqual(witness.combine(witness.identity, v), v)
        XCTAssertEqual(witness.combine(v, witness.identity), v)
    }

    func testArrayCombineMatchesElementwiseAddition() {
        let witness = [Double].additiveMonoid(length: 3)
        XCTAssertEqual(witness.combine([1, 2, 3], [4, 5, 6]), [5, 7, 9])
    }

    func testArrayReducedFoldsAcrossSequence() {
        let witness = [Double].additiveMonoid(length: 2)
        let vectors: [[Double]] = [[1, 2], [3, 4], [5, 6]]
        XCTAssertEqual(vectors.reduced(using: witness), [9, 12])
    }
}
