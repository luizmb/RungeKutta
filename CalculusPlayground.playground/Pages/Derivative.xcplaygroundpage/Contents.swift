import Calculus
import Foundation

scope("") {
    derivative { x in
        3 * x * x + 2 * x - 1
        }(3)
}

scope("") {
    derivativePerpendicular { x in
        x * (3 * x - 5)
        }(1/2)
}

scope("") {
    derivative(h: 1e-16) { x in
        x < 3.0 ? 5.0 - 2.0 * x : 4.0 * x - 13.0
        }(3)
    derivative(h: -1e-16) { x in
        x < 3.0 ? 5.0 - 2.0 * x : 4.0 * x - 13.0
        }(3)
}

scope("") {
    derivative(h: 1e-16) { x in
        x < 1 ? pow(x, 2) : 2 * x - 1
        }(1)
    derivative(h: -1e-16) { x in
        x < 1 ? pow(x, 2) : 2 * x - 1
        }(1)
}

scope("") {
    let fn: DecimalFn = { x in pow(x, 2) - 2 * x }
    let point: Decimal = 3
    fn(point)
    fn(point + 1e-16)
    fn(point - 1e-16)
    derivative(h: 1e-16, fn)(point)
    derivative(h: -1e-16, fn)(point)
    isDifferentiable(at: point, fn)
}

scope("") {
    let fn: DecimalFn = { x in x > 3 ? 10 - x : 3 * x - 2 }
    let point: Decimal = 3
    fn(point)
    fn(point + 1e-16)
    fn(point - 1e-16)
    derivative(h: 1e-16, fn)(point)
    derivative(h: -1e-16, fn)(point)
    isDifferentiable(at: point, fn)
}

scope("") {
    let fn: DecimalFn = { x in 2 * abs(x - 3) }
    let point: Decimal = 3
    fn(point)
    fn(point + 1e-16)
    fn(point - 1e-16)
    derivative(h: 1e-16, fn)(point)
    derivative(h: -1e-16, fn)(point)
    isDifferentiable(at: point, fn)
}

scope("") {
    let fn: DecimalFn = { x in x < 1 ? x : 2 * x - 1 }
    let point: Decimal = 1
    fn(point)
    fn(point + 1e-16)
    fn(point - 1e-16)
    derivative(h: 1e-16, fn)(point)
    derivative(h: -1e-16, fn)(point)
    isDifferentiable(at: point, fn)
}

scope("") {
    let fn: DecimalFn = { x in pow(x, (1/3)) }
    let point: Decimal = 0
    fn(point)
    fn(point + 1e-16)
    fn(point - 1e-16)
    derivative(h: 1e-16, fn)(point)
    derivative(h: -1e-16, fn)(point)
    isDifferentiable(at: point, fn)
}()
