import Math
import XCTest

final class VectorFPTests: XCTestCase {
    // MARK: - Functor

    func testFmapIsCurriedMapVector() {
        let double = AcceleratedVector.fmap { $0 * 2 }
        XCTAssertEqual(double(AcceleratedVector([1.0, 2.0, 3.0])), AcceleratedVector([2.0, 4.0, 6.0]))
    }

    func testFmapComposesCleanly() {
        let plus1 = AcceleratedVector.fmap { $0 + 1 }
        let times2 = AcceleratedVector.fmap { $0 * 2 }
        let composed: (AcceleratedVector) -> AcceleratedVector = { v in times2(plus1(v)) }
        XCTAssertEqual(composed(AcceleratedVector([1.0, 2.0, 3.0])), AcceleratedVector([4.0, 6.0, 8.0]))
    }

    // MARK: - Monad

    func testBindFlattensVectorOfVectors() {
        // Each element x produces a 2-element vector [x, -x].
        let duplicate = AcceleratedVector.bind { x in AcceleratedVector([x, -x]) }
        XCTAssertEqual(duplicate(AcceleratedVector([1.0, 2.0])), AcceleratedVector([1.0, -1.0, 2.0, -2.0]))
    }

    func testKleisliComposesEffectfulFunctions() {
        let f: @Sendable (Double) -> AcceleratedVector = { x in AcceleratedVector([x, x + 1]) }
        let g: @Sendable (Double) -> AcceleratedVector = { x in AcceleratedVector([x * 10]) }
        let composed = AcceleratedVector.kleisli(f, g)
        // f(2) = [2, 3]; g applied to each = [20, 30]; flattened = [20, 30]
        XCTAssertEqual(composed(2.0), AcceleratedVector([20.0, 30.0]))
    }

    // MARK: - Applicative

    func testLiftA2DoesCartesianProduct() {
        let combine = AcceleratedVector.liftA2(+)
        XCTAssertEqual(
            combine(AcceleratedVector([1.0, 2.0]), AcceleratedVector([10.0, 20.0])),
            AcceleratedVector([11.0, 21.0, 12.0, 22.0])
        )
    }

    func testApplyAcrossFunctionVector() {
        let functions: [@Sendable (Double) -> Double] = [{ $0 + 1 }, { $0 * 2 }]
        let result = AcceleratedVector.apply(functions, AcceleratedVector([10.0, 20.0]))
        XCTAssertEqual(result, AcceleratedVector([11.0, 21.0, 20.0, 40.0]))
    }
}
