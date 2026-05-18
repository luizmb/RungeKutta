import Foundation
@testable import Calculus
import XCTest

class FnFibonacciTests: XCTestCase {
    func testFibonacci() {
        let sequence: [Double] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
        sequence.enumerated().forEach { index, expected in
            XCTAssertEqual(Fibonacci.quickMethod(Double(index)), expected, accuracy: 1e-10)
        }
    }

    func testSpeedQuickFibo() {
        measure {
            (0...100).forEach { index in
                _ = Fibonacci.quickMethod(Double(index))
            }
        }
    }
    func testSpeedBalancedFibo() {
        measure {
            (0...100).forEach { index in
                _ = Fibonacci.balancedMethod(Double(index))
            }
        }
    }
    func testSpeedPreciseFibo() {
        measure {
            (0...100).forEach { index in
                _ = Fibonacci.preciseMethod(Double(index))
            }
        }
    }
    func testCompareFiboAlgorithmPrecision() {
        zip(
            zip(
                Fibonacci(method: .quick),
                Fibonacci(method: .balanced)
            ),
            Fibonacci(method: .precise)
        )
        .prefix(101)
        .map { ($0.0, $0.1, $1) }
        .enumerated()
        .forEach { index, tuple in
            let (quickFibo, balancedFibo, preciseFibo) = tuple

            print("idx \(index)\t|QuickFibo: \(quickFibo)\tBalancedFibo: \(balancedFibo)\tPreciseFibo: \(preciseFibo)")
            let accuracyQuick: Double = switch index {
            case 0..<10: 1e-14
            case 10..<20: 1e-11
            case 20..<30: 1e-9
            case 30..<40: 1e-7
            case 40..<50: 1e-4
            case 50..<60: 1e-2
            case 60..<70: 1e0
            case 70..<80: 1e2
            case 80..<90: 1e4
            default: 1e7
            }
            let accuracyBalanced: Double = switch index {
            case 0..<10: 1e-32
            case 10..<20: 1e-32
            case 20..<30: 1e-32
            case 30..<40: 1e-32
            case 40..<50: 1e-32
            case 50..<60: 1e-32
            case 60..<70: 1e-32
            case 70..<80: 1e1
            case 80..<90: 1e3
            default: 1e5
            }
            XCTAssertEqual(quickFibo, preciseFibo, accuracy: accuracyQuick, "Quick Fibo, idx #\(index), difference: \(preciseFibo - quickFibo), should be below \(accuracyQuick)")
            XCTAssertEqual(balancedFibo, preciseFibo, accuracy: accuracyBalanced, "Balanced Fibo idx #\(index), difference: \(preciseFibo - balancedFibo), should be below \(accuracyBalanced)")
        }
    }
}
