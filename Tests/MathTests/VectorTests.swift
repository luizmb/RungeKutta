import Math
import XCTest

final class VectorTests: XCTestCase {
    // MARK: - Construction + conversions

    func testInitFromArray() {
        let v = Vector([1.0, 2.0, 3.0])
        XCTAssertEqual(v.storage, [1.0, 2.0, 3.0])
    }

    func testVariadicInit() {
        let v = Vector(1.0, 2.0, 3.0)
        XCTAssertEqual(v.storage, [1.0, 2.0, 3.0])
    }

    func testAsVectorExtensionOnArray() {
        let array = [1.0, 2.0, 3.0]
        let v = array.asVector
        XCTAssertEqual(v.storage, array)
    }

    func testIsEmptyAndCount() {
        XCTAssertTrue(Vector([]).isEmpty)
        XCTAssertEqual(Vector([1.0, 2.0]).count, 2)
    }

    // MARK: - Collection conformance

    func testIterationViaForEach() {
        let v = Vector([1.0, 2.0, 3.0])
        var sum = 0.0
        for x in v { sum += x }
        XCTAssertEqual(sum, 6.0)
    }

    func testSubscriptAccess() {
        let v = Vector([10.0, 20.0, 30.0])
        XCTAssertEqual(v[0], 10.0)
        XCTAssertEqual(v[1], 20.0)
        XCTAssertEqual(v[2], 30.0)
    }

    func testCollectionMapReturnsArray() {
        let v = Vector([1.0, 2.0, 3.0])
        let doubled: [Double] = v.map { $0 * 2 }   // Collection.map → [T]
        XCTAssertEqual(doubled, [2.0, 4.0, 6.0])
    }

    func testMapVectorPreservesType() {
        let v = Vector([1.0, 2.0, 3.0])
        let doubled = v.mapVector { $0 * 2 }
        XCTAssertEqual(doubled, Vector([2.0, 4.0, 6.0]))
    }

    func testFilterReducesToArray() {
        let v = Vector([1.0, -2.0, 3.0, -4.0])
        let positives = v.filter { $0 > 0 }
        XCTAssertEqual(positives, [1.0, 3.0])
    }

    func testReduceWorks() {
        XCTAssertEqual(Vector([1.0, 2.0, 3.0]).reduce(0, +), 6.0)
    }

    // MARK: - Equality + hashing

    func testEqualityHonorsStorage() {
        XCTAssertEqual(Vector([1.0, 2.0]), Vector([1.0, 2.0]))
        XCTAssertNotEqual(Vector([1.0, 2.0]), Vector([1.0, 2.0, 3.0]))
    }

    // MARK: - Arithmetic

    func testAddition() {
        XCTAssertEqual(Vector([1.0, 2.0, 3.0]) + Vector([10.0, 20.0, 30.0]),
                       Vector([11.0, 22.0, 33.0]))
    }

    func testSubtraction() {
        XCTAssertEqual(Vector([10.0, 20.0, 30.0]) - Vector([1.0, 2.0, 3.0]),
                       Vector([9.0, 18.0, 27.0]))
    }

    func testScalarMultiplication() {
        XCTAssertEqual(3.0 * Vector([1.0, 2.0, 3.0]),
                       Vector([3.0, 6.0, 9.0]))
    }

    func testInPlaceAdd() {
        var acc = Vector([1.0, 2.0, 3.0])
        acc += Vector([10.0, 20.0, 30.0])
        XCTAssertEqual(acc, Vector([11.0, 22.0, 33.0]))
    }

    func testInPlaceSubtract() {
        var acc = Vector([10.0, 20.0, 30.0])
        acc -= Vector([1.0, 2.0, 3.0])
        XCTAssertEqual(acc, Vector([9.0, 18.0, 27.0]))
    }

    func testInPlaceScalarMul() {
        var acc = Vector([1.0, 2.0, 3.0])
        acc *= 2.0
        XCTAssertEqual(acc, Vector([2.0, 4.0, 6.0]))
    }

    // MARK: - NormedVectorState

    func testInfinityNormPositiveValues() {
        XCTAssertEqual(Vector([1.0, 5.0, 3.0]).infinityNorm, 5.0)
    }

    func testInfinityNormHandlesNegatives() {
        XCTAssertEqual(Vector([1.0, -7.0, 3.0]).infinityNorm, 7.0)
    }

    func testInfinityNormEmptyVectorReturnsZero() {
        XCTAssertEqual(Vector([]).infinityNorm, 0.0)
    }

    // MARK: - Bridge with Matrix

    func testMatrixApplyOnVector() {
        let A = Matrix<Double>(rows: 2, columns: 3, storage: [
            1, 2, 3,
            4, 5, 6
        ])
        let v = Vector([1.0, 2.0, 3.0])
        let result = A.apply(to: v)
        XCTAssertEqual(result, Vector([14.0, 32.0]))   // [1+4+9, 4+10+18]
    }
}
