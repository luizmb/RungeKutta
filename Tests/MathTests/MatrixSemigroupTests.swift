import CoreFP
import Math
import MathOperators
import XCTest

final class MatrixSemigroupTests: XCTestCase {
    // MARK: - Additive

    func testAdditiveCombineMatchesElementwiseAddition() {
        let lhs = Matrix<Double>.Additive(Matrix(rows: 2, columns: 2, storage: [1, 2, 3, 4]))
        let rhs = Matrix<Double>.Additive(Matrix(rows: 2, columns: 2, storage: [5, 6, 7, 8]))
        XCTAssertEqual(
            Matrix<Double>.Additive.combine(lhs, rhs).rawValue,
            lhs.rawValue + rhs.rawValue
        )
    }

    func testAdditiveAssociativity() {
        let A = Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [1, 2]))
        let B = Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [3, 4]))
        let C = Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [5, 6]))
        XCTAssertEqual(
            Matrix<Double>.Additive.combine(Matrix<Double>.Additive.combine(A, B), C).rawValue,
            Matrix<Double>.Additive.combine(A, Matrix<Double>.Additive.combine(B, C)).rawValue
        )
    }

    func testAdditiveSconcatFoldsThroughCombine() {
        let matrices: [Matrix<Double>.Additive] = [
            Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [1, 2])),
            Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [3, 4])),
            Matrix<Double>.Additive(Matrix(rows: 1, columns: 2, storage: [5, 6]))
        ]
        let result = sconcat(matrices[0], Array(matrices.dropFirst()))
        XCTAssertEqual(result.rawValue, Matrix(rows: 1, columns: 2, storage: [9, 12]))
    }

    // MARK: - Multiplicative

    func testMultiplicativeCombineMatchesMatrixMultiplication() {
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 2, 3, 4])
        let B = Matrix<Double>(rows: 2, columns: 2, storage: [5, 6, 7, 8])
        XCTAssertEqual(
            Matrix<Double>.Multiplicative.combine(
                Matrix<Double>.Multiplicative(A),
                Matrix<Double>.Multiplicative(B)
            ).rawValue,
            A * B
        )
    }

    func testMultiplicativeAssociativity() {
        let a = Matrix<Double>(rows: 2, columns: 2, storage: [1, 1, 0, 1])
        let b = Matrix<Double>(rows: 2, columns: 2, storage: [1, 0, 1, 1])
        let c = Matrix<Double>(rows: 2, columns: 2, storage: [2, 0, 0, 2])
        let A = Matrix<Double>.Multiplicative(a)
        let B = Matrix<Double>.Multiplicative(b)
        let C = Matrix<Double>.Multiplicative(c)
        XCTAssertEqual(
            Matrix<Double>.Multiplicative.combine(
                Matrix<Double>.Multiplicative.combine(A, B),
                C
            ).rawValue,
            Matrix<Double>.Multiplicative.combine(
                A,
                Matrix<Double>.Multiplicative.combine(B, C)
            ).rawValue
        )
    }

    func testMultiplicativeSconcatFoldsThroughCombine() {
        // [[1,1],[0,1]]^4 should be [[1,4],[0,1]]
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [1, 1, 0, 1])
        let wrapped = Array(repeating: Matrix<Double>.Multiplicative(A), count: 4)
        let result = sconcat(wrapped[0], Array(wrapped.dropFirst()))
        XCTAssertEqual(result.rawValue, Matrix(rows: 2, columns: 2, storage: [1, 4, 0, 1]))
    }
}
