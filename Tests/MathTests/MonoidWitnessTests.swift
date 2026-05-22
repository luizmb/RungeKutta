import Math
import XCTest

final class MonoidWitnessTests: XCTestCase {
    // Use Int's natural additive monoid for a small concrete witness — the laws
    // here are about MonoidWitness's mechanics, not about Int.
    private let sum = MonoidWitness<Int>(identity: 0, combine: +)
    private let product = MonoidWitness<Int>(identity: 1, combine: *)

    func testIdentityCombinedLeftReturnsValue() {
        XCTAssertEqual(sum.combine(sum.identity, 42), 42)
        XCTAssertEqual(product.combine(product.identity, 42), 42)
    }

    func testIdentityCombinedRightReturnsValue() {
        XCTAssertEqual(sum.combine(42, sum.identity), 42)
        XCTAssertEqual(product.combine(42, product.identity), 42)
    }

    func testCombineIsAssociative() {
        XCTAssertEqual(sum.combine(sum.combine(3, 5), 7), sum.combine(3, sum.combine(5, 7)))
        XCTAssertEqual(product.combine(product.combine(3, 5), 7), product.combine(3, product.combine(5, 7)))
    }

    func testIterateZeroIsIdentity() {
        XCTAssertEqual(sum.iterate(5, count: 0), 0)
        XCTAssertEqual(product.iterate(5, count: 0), 1)
    }

    func testIterateOnceIsValue() {
        XCTAssertEqual(sum.iterate(5, count: 1), 5)
        XCTAssertEqual(product.iterate(5, count: 1), 5)
    }

    func testIterateMatchesRepeatedCombine() {
        XCTAssertEqual(sum.iterate(5, count: 4), 5 + 5 + 5 + 5)
        XCTAssertEqual(product.iterate(2, count: 5), 32)
    }

    func testReducedFoldsThroughIdentityForEmptySequence() {
        XCTAssertEqual([Int]().reduced(using: sum), 0)
        XCTAssertEqual([Int]().reduced(using: product), 1)
    }

    func testReducedFoldsSequenceThroughCombine() {
        XCTAssertEqual([1, 2, 3, 4].reduced(using: sum), 10)
        XCTAssertEqual([1, 2, 3, 4].reduced(using: product), 24)
    }
}
