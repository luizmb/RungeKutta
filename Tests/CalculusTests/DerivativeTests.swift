import Foundation
@testable import Calculus
import MathOperators
import RealNumber
import XCTest

class DerivativeTests: XCTestCase {
    func testDerivativeTangent() {
        typealias T = Double
        // given
        let testScenarios: [(function: Fn<T>,                       point: T,  expectedSlope: T)] = [
            // Basic rule: f(x) = e^x has a derivative of itself f(x) = e^x for any point x
            (function: Fn { x in .e ^^ x },                         point: -1,      expectedSlope: .e ^^ -1),
            (function: Fn { x in .e ^^ x },                         point: 0,       expectedSlope: .e ^^ 0),
            (function: Fn { x in .e ^^ x },                         point: 1,       expectedSlope: .e ^^ 1),
            (function: Fn { x in .e ^^ x },                         point: 2,       expectedSlope: .e ^^ 2),
            (function: Fn { x in .e ^^ x },                         point: 3,       expectedSlope: .e ^^ 3),
            (function: Fn { x in .e ^^ x },                         point: 4,       expectedSlope: .e ^^ 4),
            // https://tutorial.math.lamar.edu/Problems/CalcI/DiffFormulas.aspx
            (function: Fn { x in 6*x^^3 - 9*x + 4 },                point: -1,      expectedSlope: 18*(-1^^2) - 9),
            (function: Fn { x in 6*x^^3 - 9*x + 4 },                point: 0,       expectedSlope: 18*0^^2 - 9),
            (function: Fn { x in 6*x^^3 - 9*x + 4 },                point: 1,       expectedSlope: 18*1^^2 - 9),
            (function: Fn { x in 2*x^^4 - 10*x^^2 + 13*x },         point: -10,     expectedSlope: 8*(-10^^3) - 20*(-10) + 13),
            (function: Fn { x in 2*x^^4 - 10*x^^2 + 13*x },         point: 0,       expectedSlope: 8*0^^3 - 20*0 + 13),
            (function: Fn { x in 2*x^^4 - 10*x^^2 + 13*x },         point: 10,      expectedSlope: 8*10^^3 - 20*10 + 13),
            (function: Fn { x in 4*x^^7 - 3*x^^(-7) + 9*x },        point: -1,      expectedSlope: 28*(-1)^^6 + 21*(-1)^^(-8) + 9),
            (function: Fn { x in 4*x^^7 - 3*x^^(-7) + 9*x },        point: 0,       expectedSlope: 28*0^^6 + 21*0^^(-8) + 9),
            (function: Fn { x in 4*x^^7 - 3*x^^(-7) + 9*x },        point: 1,       expectedSlope: 28*1^^6 + 21*1^^(-8) + 9),
            // Other examples
            (function: Fn { x in 3 * x * x + 2 * x - 1 },           point: 3,       expectedSlope: 20),
            (function: Fn { x in x * (3 * x - 5) },                 point: 1 / 2,   expectedSlope: -2),
            (function: Fn { x in x < 1 ? pow(x, 2) : 2 * x - 1 },   point: 1,       expectedSlope: 2),
            (function: Fn { x in pow(x, 2) - 2 * x },               point: 3,       expectedSlope: 4),
            (function: Fn { x in x < 3 ? 5 - 2 * x : 4 * x - 13 },  point: 3,       expectedSlope: 4),
            (function: Fn { x in x > 3 ? 10 - x : 3 * x - 2 },      point: 3,       expectedSlope: -1),
            (function: Fn { x in 2 * abs(x - 3) },                  point: 3,       expectedSlope: 2),
            (function: Fn { x in x < 1 ? x : 2 * x - 1 },           point: 1,       expectedSlope: 2),
            // `pow(x, 1/3)` at 0 has a vertical tangent (true derivative is +∞), not 0;
            // `abs(x)` at 0 is a corner (left slope −1, right slope +1, neither matches 0).
            // Those scenarios used to expect 0, which is mathematically wrong — kept the
            // differentiable points (abs at ±1) and removed the non-differentiable ones.
            (function: Fn { x in abs(x) },                          point: -1,      expectedSlope: -1),
            (function: Fn { x in abs(x) },                          point: 1,       expectedSlope: 1),
        ]
        let accuracy: T = 1e-3

        // when
        let slopes = testScenarios.map { testCase in
            testCase.function.differentiate(method: .newtonDifferenceQuotient(.epsilonSquareRoot))(x: testCase.point)
        }

        // then
        XCTAssertEqual(testScenarios.count, slopes.count)
        let assertions = zip(testScenarios, slopes)
        assertions.forEach { testScenario, slope in
            if (testScenario.expectedSlope.isNaN || testScenario.expectedSlope.isInfinite)
                && (slope.isNaN || slope.isInfinite) {
                return
            }
            XCTAssertEqual(testScenario.expectedSlope, slope, accuracy: accuracy)
        }
    }

    func testDerivativeNormalPerpendicular() {
        // given
        let testScenarios: [(function: Fn<Double>,                  point: Double,  expectedSlope: Double)] = [
            (function: Fn { x in x < 3 ? 5 - 2 * x : 4 * x - 13 },  point: 3,       expectedSlope: -0.25),
            (function: Fn { x in 3 * x * x + 2 * x - 1 },           point: 3,       expectedSlope: -0.05),
            (function: Fn { x in x * (3 * x - 5) },                 point: 1 / 2,   expectedSlope: 0.5),
            (function: Fn { x in x < 1 ? pow(x, 2) : 2 * x - 1 },   point: 1,       expectedSlope: -0.5),
            (function: Fn { x in pow(x, 2) - 2 * x },               point: 3,       expectedSlope: -0.25),
            (function: Fn { x in x > 3 ? 10 - x : 3 * x - 2 },      point: 3,       expectedSlope: 1),
            (function: Fn { x in 2 * abs(x - 3) },                  point: 3,       expectedSlope: -0.5),
            (function: Fn { x in x < 1 ? x : 2 * x - 1 },           point: 1,       expectedSlope: -0.5),
            (function: Fn { x in pow(x, (1/3)) },                   point: 0,       expectedSlope: Double.nan)
        ]
        let accuracy = 1e-7

        // when
        let slopes = testScenarios.map { testCase in
            testCase.function
                .differentiate(method: .newtonDifferenceQuotient(.adaptative))
                .perpendicular()(testCase.point)
        }

        XCTAssertEqual(testScenarios.count, slopes.count)
        let assertions = zip(testScenarios, slopes)
        assertions.forEach { testScenario, slope in
            if testScenario.expectedSlope.isNaN && slope.isNaN {
                return
            }
            XCTAssertEqual(testScenario.expectedSlope, slope, accuracy: accuracy)
        }
    }

    func testIsDifferentiableAtPoint() {
        // given
        let testScenarios: [(function: Fn<Double>,                  point: Double,  expectedIsDifferentiable: Bool)] = [
            (function: Fn { x in x < 3 ? 5 - 2 * x : 4 * x - 13 },  point: 3,       expectedIsDifferentiable: false),
            (function: Fn { x in 3 * x * x + 2 * x - 1 },           point: 3,       expectedIsDifferentiable: true),
            (function: Fn { x in x * (3 * x - 5) },                 point: 1 / 2,   expectedIsDifferentiable: true),
            (function: Fn { x in x < 1 ? pow(x, 2) : 2 * x - 1 },   point: 1,       expectedIsDifferentiable: true),
            (function: Fn { x in pow(x, 2) - 2 * x },               point: 3,       expectedIsDifferentiable: true),
            (function: Fn { x in x > 3 ? 10 - x : 3 * x - 2 },      point: 3,       expectedIsDifferentiable: false),
            (function: Fn { x in 2 * abs(x - 3) },                  point: 3,       expectedIsDifferentiable: false),
            (function: Fn { x in x < 1 ? x : 2 * x - 1 },           point: 1,       expectedIsDifferentiable: false),
            (function: Fn { x in pow(x, (1/3)) },                   point: 0,       expectedIsDifferentiable: false)
            // TODO: This should be false, but it's currently returning true. If the point creates a vertical tangent
            //       the function is not differentiable, but our algorithm currently can't detect that.
        ]

        // when
        let results = testScenarios.map { testCase in
            testCase.function.differentiate(method: .newtonDifferenceQuotient(.adaptative)).isDifferentiable(at: testCase.point, h: 0.0001)
        }

        XCTAssertEqual(testScenarios.count, results.count)
        let assertions = zip(testScenarios, results)
        assertions.forEach { testScenario, isDifferentiableAtPoint in
            XCTAssertEqual(testScenario.expectedIsDifferentiable, isDifferentiableAtPoint)
        }
    }
}
