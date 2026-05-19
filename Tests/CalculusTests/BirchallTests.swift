import XCTest
@testable import Calculus
@testable import Math

final class BirchallTests: XCTestCase {
    private let tolerance = 1e-10

    func testExpOfZeroIsIdentity() {
        assertEqual(Birchall.matrixExponential(Matrix<Double>.zero(size: 4)), Matrix<Double>.identity(size: 4))
    }

    func testExpOfDiagonalMatrix() {
        // exp(diag(d₁, d₂, …)) = diag(e^d₁, e^d₂, …) — even when scaling kicks in.
        let D = Matrix<Double>(rows: 3, columns: 3, storage: [
            -0.5, 0, 0,
            0, -1.0, 0,
            0, 0, -2.0
        ])
        let result = Birchall.matrixExponential(D)
        let expected = Matrix<Double>(rows: 3, columns: 3, storage: [
            exp(-0.5), 0, 0,
            0, exp(-1.0), 0,
            0, 0, exp(-2.0)
        ])
        assertEqual(result, expected)
    }

    func testExpOfTwoCompartmentDecay() {
        // A = [[-kt, 0], [kt, 0]]. Closed-form e^A = [[e^{-kt}, 0], [1 - e^{-kt}, 1]].
        let k = 0.3
        let t = 5.0
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [
            -k * t, 0,
            k * t, 0
        ])
        let expected = Matrix<Double>(rows: 2, columns: 2, storage: [
            exp(-k * t), 0,
            1 - exp(-k * t), 1
        ])
        assertEqual(Birchall.matrixExponential(A), expected)
    }

    func testExpOfNegativeIdentityIsScaledIdentity() {
        let c = 0.7
        let A = -c * Matrix<Double>.identity(size: 4)
        assertEqual(Birchall.matrixExponential(A), exp(-c) * Matrix<Double>.identity(size: 4))
    }

    func testExpOfLargeMagnitudeMatrix() {
        // ‖A‖ large enough that raw Taylor would cancel catastrophically.
        // Birchall's scaling must rescue accuracy.
        let A = Matrix<Double>(rows: 2, columns: 2, storage: [
            -100, 0,
            0, -50
        ])
        let result = Birchall.matrixExponential(A)
        XCTAssertEqual(result[0, 0], exp(-100), accuracy: 1e-50)
        XCTAssertEqual(result[1, 1], exp(-50), accuracy: 1e-25)
    }

    func testScalingPowerForBelowThreshold() {
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: 0), 0)
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: -0.1), 0)
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: -0.19), 0)
    }

    func testScalingPowerScalesUntilUnderThreshold() {
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: -0.2), 1)
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: -0.4), 2)
        // 100 / 2^9 ≈ 0.195 < 0.2; 100 / 2^8 ≈ 0.391 > 0.2 ⇒ k = 9.
        XCTAssertEqual(Birchall.scalingPower(forMinDiagonal: -100), 9)
    }

    private func assertEqual(_ lhs: Matrix<Double>, _ rhs: Matrix<Double>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(lhs.rows, rhs.rows, file: file, line: line)
        XCTAssertEqual(lhs.columns, rhs.columns, file: file, line: line)
        for (l, r) in zip(lhs.storage, rhs.storage) {
            XCTAssertEqual(l, r, accuracy: tolerance, file: file, line: line)
        }
    }
}
