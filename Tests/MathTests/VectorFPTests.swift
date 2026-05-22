import Math
import XCTest

final class VectorFPTests: XCTestCase {
    // MARK: - Functor

    func testFmapIsCurriedMapVector() {
        let double = Vector.fmap { $0 * 2 }
        XCTAssertEqual(double(Vector([1.0, 2.0, 3.0])), Vector([2.0, 4.0, 6.0]))
    }

    func testFmapComposesCleanly() {
        let plus1 = Vector.fmap { $0 + 1 }
        let times2 = Vector.fmap { $0 * 2 }
        let composed: (Vector) -> Vector = { v in times2(plus1(v)) }
        XCTAssertEqual(composed(Vector([1.0, 2.0, 3.0])), Vector([4.0, 6.0, 8.0]))
    }

    // MARK: - Monad

    func testBindFlattensVectorOfVectors() {
        // Each element x produces a 2-element vector [x, -x].
        let duplicate = Vector.bind { x in Vector([x, -x]) }
        XCTAssertEqual(duplicate(Vector([1.0, 2.0])), Vector([1.0, -1.0, 2.0, -2.0]))
    }

    func testKleisliComposesEffectfulFunctions() {
        let f: @Sendable (Double) -> Vector = { x in Vector([x, x + 1]) }
        let g: @Sendable (Double) -> Vector = { x in Vector([x * 10]) }
        let composed = Vector.kleisli(f, g)
        // f(2) = [2, 3]; g applied to each = [20, 30]; flattened = [20, 30]
        XCTAssertEqual(composed(2.0), Vector([20.0, 30.0]))
    }

    // MARK: - Applicative

    func testLiftA2DoesCartesianProduct() {
        let combine = Vector.liftA2(+)
        XCTAssertEqual(
            combine(Vector([1.0, 2.0]), Vector([10.0, 20.0])),
            Vector([11.0, 21.0, 12.0, 22.0])
        )
    }

    func testApplyAcrossFunctionVector() {
        let functions: [@Sendable (Double) -> Double] = [{ $0 + 1 }, { $0 * 2 }]
        let result = Vector.apply(functions, Vector([10.0, 20.0]))
        XCTAssertEqual(result, Vector([11.0, 21.0, 20.0, 40.0]))
    }
}
