import Math
import MathOperators
import XCTest

final class MatrixMonoidTests: XCTestCase {
    // MARK: - Additive monoid

    func testAdditiveIdentityIsZeroMatrixOfRequestedShape() {
        let witness = Matrix<Double>.additiveMonoid(rows: 2, columns: 3)
        XCTAssertEqual(witness.identity.rows, 2)
        XCTAssertEqual(witness.identity.columns, 3)
        XCTAssertTrue(witness.identity.storage.allSatisfy { $0 == 0 })
    }

    func testAdditiveIdentityCombinedLeftReturnsMatrix() {
        let witness = Matrix<Double>.additiveMonoid(rows: 2, columns: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        XCTAssertEqual(witness.combine(witness.identity, A), A)
    }

    func testAdditiveIdentityCombinedRightReturnsMatrix() {
        let witness = Matrix<Double>.additiveMonoid(rows: 2, columns: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        XCTAssertEqual(witness.combine(A, witness.identity), A)
    }

    func testAdditiveCombineMatchesElementwiseAddition() {
        let witness = Matrix<Double>.additiveMonoid(rows: 2, columns: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        let B = Matrix<Double>(rows: 2, columns: 2, storage: [5, 6, 7, 8])
        XCTAssertEqual(witness.combine(A, B), A + B)
    }

    func testAdditiveReducedAcrossSequence() {
        let witness = Matrix<Double>.additiveMonoid(rows: 1, columns: 2)
        let matrices = [
            Matrix<Double>(rows: 1, columns: 2, storage: [1, 2]),
            Matrix<Double>(rows: 1, columns: 2, storage: [3, 4]),
            Matrix<Double>(rows: 1, columns: 2, storage: [5, 6])
        ]
        XCTAssertEqual(
            matrices.reduced(using: witness),
            Matrix<Double>(rows: 1, columns: 2, storage: [9, 12])
        )
    }

    // MARK: - Multiplicative monoid

    func testMultiplicativeIdentityIsIdentityMatrix() {
        let witness = Matrix<Double>.multiplicativeMonoid(size: 3)
        XCTAssertEqual(witness.identity, Matrix<Double>.identity(size: 3))
    }

    func testMultiplicativeIdentityCombinedLeftReturnsMatrix() {
        let witness = Matrix<Double>.multiplicativeMonoid(size: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        XCTAssertEqual(witness.combine(witness.identity, A), A)
    }

    func testMultiplicativeIdentityCombinedRightReturnsMatrix() {
        let witness = Matrix<Double>.multiplicativeMonoid(size: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        XCTAssertEqual(witness.combine(A, witness.identity), A)
    }

    func testMultiplicativeCombineMatchesMatrixMultiplication() {
        let witness = Matrix<Double>.multiplicativeMonoid(size: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        let B = Matrix<Double>(rows: 2, columns: 2, storage: [5, 6, 7, 8])
        XCTAssertEqual(witness.combine(A, B), A * B)
    }

    func testMultiplicativeIterateMatchesRepeatedSquaring() {
        let witness = Matrix<Double>.multiplicativeMonoid(size: 2)
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 1, 0, 1])
        // Fibonacci-style: [[1,1],[0,1]]^4 should be [[1,4],[0,1]].
        let result = witness.iterate(A, count: 4)
        XCTAssertEqual(result, Matrix<Double>(rows: 2, columns: 2, storage: [1, 4, 0, 1]))
    }
}
