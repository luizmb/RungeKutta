import CoreFP
import Foundation
import Math
import RealNumber

public enum DerivativeFunction<T: ℝ> {
    case firstDerivative(function: Fn<T>, method: Method)
    indirect case higherOrder(derivative: DerivativeFunction<T>)

    /// "For basic central differences, the optimal step is the cube-root of machine epsilon."
    /// https://en.wikipedia.org/wiki/Numerical_differentiation#Step_size
    public enum StepCalculator {
        case epsilonSquareRoot
        case epsilonCubeRoot
        case adaptative
        case adaptativeZeroHigh
        case customHforX(Fn<T>)
        case constant(h: T)

        fileprivate func calculate(x: T, fn: Fn<T>) -> T {
            switch self {
            case .epsilonSquareRoot: T.epsilon.squareRoot()
            case .epsilonCubeRoot: T.epsilon.cubeRoot()
            case .adaptative: T.epsilon.squareRoot() * x
            case .adaptativeZeroHigh: x == 0 ? T.epsilon : T.epsilon.squareRoot() * x
            case let .customHforX(hForX): hForX(x)
            case let .constant(h): h
            }
        }
    }

    public enum Method {
        case newtonDifferenceQuotient(StepCalculator)
        case backwardDifferencing(StepCalculator)
        case symmetricDifferenceQuotient(StepCalculator)
        case fivePoint(StepCalculator)
        case custom(deriving: (Fn<T>) -> Fn<T>)

        public func deriving(fn: Fn<T>) -> Fn<T> {
            switch self {
            case let .newtonDifferenceQuotient(stepCalculator):
                Fn { x in
                    let h = stepCalculator.calculate(x: x, fn: fn)
                    return (fn(x + h) - fn(x)) / h
                }
            case let .backwardDifferencing(stepCalculator):
                Fn { x in
                    let h = stepCalculator.calculate(x: x, fn: fn)
                    return (fn(x) - fn(x - h)) / h
                }
            case let .symmetricDifferenceQuotient(stepCalculator):
                Fn { x in
                    let h = stepCalculator.calculate(x: x, fn: fn)
                    return (fn(x + h) - fn(x - h)) / (2*h)
                }
            case let .fivePoint(stepCalculator):
                Fn { x in
                    let h = stepCalculator.calculate(x: x, fn: fn)
                    let firstPoint = -fn(x + 2*h)
                    let secondPoint = 8*fn(x + h)
                    let thirdPoint = -8*fn(x - h)
                    let fourthPoint = fn(x - 2*h)
                    let leftGroup = (firstPoint + secondPoint + thirdPoint + fourthPoint) / (12 * h)
                    let c1 = x - 2 * h
                    let c2 = x + 2 * h
                    let fifthPoint = (h.raisedToThePower(of: 4) / 30) * fn(5) * c2
                    return leftGroup + fifthPoint
                }
            case let .custom(dx):
                dx(fn)
            }
        }
    }

    public var method: Method {
        switch self {
        case let .firstDerivative(_, method):
            method
        case let .higherOrder(derivative):
            derivative.method
        }
    }

    public var slopeFunction: Fn<T> {
        Fn { x in
            let innerFunction = switch self {
            case let .firstDerivative(function, _):
                function
            case let .higherOrder(derivative):
                derivative.slopeFunction
            }

            return method.deriving(fn: innerFunction)(x)
        }
    }

    public func perpendicular() -> Fn<T> {
        slopeFunction
            .invert()
    }

    public func callAsFunction(x: T) -> T {
        slopeFunction(x)
    }

    public func isDifferentiable(at x: T, h: T) -> Bool {
        // TODO: `{ x in pow(x, (1/3)) }, point: 0, expectedIsDifferentiable: false`
        //       This should be false, but it's currently returning true. If the point creates a vertical tangent
        //       the function is not differentiable, but our algorithm currently can't detect that.
        let fromLeft = self(x: x)
        let fromRight = self(x: x)

        return abs(fromLeft - fromRight) < h
    }
}

extension DerivativeFunction {
    public func differentiate() -> DerivativeFunction<T> {
        DerivativeFunction.higherOrder(derivative: self)
    }
}

extension Endo where A: ℝ {
    public func differentiate(method: DerivativeFunction<A>.Method) -> DerivativeFunction<A> {
        DerivativeFunction.firstDerivative(function: self, method: method)
    }

    public func point(at x: A) -> BidimensionalPoint<A>? {
        let y = self(x)
        guard !x.isNaN, !y.isNaN else { return nil }
        return BidimensionalPoint(x: x, y: y)
    }

    public func invert() -> Self {
        Self { x in
            -1 / self(x)
        }
    }
}
