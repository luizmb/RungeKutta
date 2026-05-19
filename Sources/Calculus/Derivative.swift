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
                    // Five-point central-difference stencil:
                    //   f'(x) ≈ [ −f(x + 2h) + 8·f(x + h) − 8·f(x − h) + f(x − 2h) ] / (12h)
                    // Derived by combining Taylor expansions to cancel the O(h²) and O(h³) error
                    // terms; the remaining error is O(h⁴). See e.g.
                    // https://en.wikipedia.org/wiki/Five-point_stencil
                    let firstPoint = -fn(x + 2*h)
                    let secondPoint = 8*fn(x + h)
                    let thirdPoint = -8*fn(x - h)
                    let fourthPoint = fn(x - 2*h)
                    return (firstPoint + secondPoint + thirdPoint + fourthPoint) / (12 * h)
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
        slopeFunction.perpendicularSlope()
    }

    public func callAsFunction(x: T) -> T {
        slopeFunction(x)
    }

    /// True if `fn` looks differentiable at `x`: the backward and forward difference
    /// quotients at step `h` agree to within `h`. Catches corners (e.g. `|x|` at 0,
    /// where left slope is −1 and right slope is +1) and jumps in the derivative.
    ///
    /// **Known limitation:** does *not* catch vertical-tangent points like
    /// `x^(1/3)` at 0, where the function is not differentiable but the left and right
    /// derivatives agree (both are +∞). Detecting those would require checking the
    /// *magnitude* of the slope against some threshold, which depends on the use case.
    /// True if `fn` looks differentiable at `x`: the backward and forward difference
    /// quotients at step `h` agree to within `√h`.
    ///
    /// The `√h` (not `h`) tolerance matters: even perfectly smooth functions have
    /// finite-difference truncation error of order `O(h)` from one-sided differences,
    /// so a `< h` threshold would reject everything. Corners (`|x|` at 0) have a
    /// **constant** slope jump independent of `h` — they fail the `√h` threshold
    /// cleanly. Vertical-tangent points (`x^(1/3)` at 0) also fail because Swift's
    /// `pow(-h, 1/3)` returns `NaN`, which makes `fromLeft` `NaN`, and `NaN < anything`
    /// is `false`.
    public func isDifferentiable(at x: T, h: T) -> Bool {
        let fn = underlyingFunction
        let fromLeft = (fn(x) - fn(x - h)) / h
        let fromRight = (fn(x + h) - fn(x)) / h
        return abs(fromLeft - fromRight) < h.squareRoot()
    }

    /// The function being differentiated. For a chain of `.higherOrder` cases this is
    /// the previous derivative (one rung down the chain), reaching the original
    /// `.firstDerivative` function at the bottom.
    public var underlyingFunction: Fn<T> {
        switch self {
        case let .firstDerivative(function, _):
            function
        case let .higherOrder(derivative):
            derivative.slopeFunction
        }
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

    /// Returns the perpendicular-slope function: at every point, the negative
    /// reciprocal of `self(x)`. If `self` is a tangent slope, this is the slope of
    /// the line perpendicular to it.
    ///
    /// (This used to be named `invert()`, which was misleading — it computes the
    /// negative reciprocal, not the function inverse.)
    public func perpendicularSlope() -> Self {
        Self { x in
            -1 / self(x)
        }
    }
}
