import RealNumber

/// State type that supports the linear operations RK-style integrators require:
/// elementwise addition with another state, and scaling by a real-number coefficient.
///
/// Conform any type that behaves as a vector over an ``ℝ`` scalar. `Array<Scalar>`
/// has a built-in conformance using elementwise operations.
public protocol VectorState {
    associatedtype Scalar: ℝ
    static func + (lhs: Self, rhs: Self) -> Self
    static func * (scalar: Scalar, state: Self) -> Self
}

extension Array: VectorState where Element: ℝ {
    public typealias Scalar = Element

    public static func + (lhs: Array<Element>, rhs: Array<Element>) -> Array<Element> {
        zip(lhs, rhs).map(+)
    }

    public static func * (scalar: Element, state: Array<Element>) -> Array<Element> {
        state.map { scalar * $0 }
    }
}
