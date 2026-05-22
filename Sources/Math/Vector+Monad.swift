import RealNumber

extension Vector {
    /// Curried version of `flatMap`-into-`Vector` for functional composition.
    /// Mirrors `Array.bind` from FP's `CoreFP`.
    ///
    ///     (>>=) :: m a -> (a -> m b) -> m b
    ///
    /// Composes per-element transformations that themselves produce vectors,
    /// flattening the result. The element type is fixed to `Double` (both
    /// input and output) because `Vector` is concretely `[Double]`.
    public static func bind(
        _ fn: @escaping @Sendable (Double) -> Vector
    ) -> @Sendable (Vector) -> Vector {
        { vector in Vector(vector.storage.flatMap { fn($0).storage }) }
    }

    /// Kleisli composition (left-to-right) over `Vector`.
    /// Mirrors `Array.kleisli` from FP's `CoreFP`.
    ///
    ///     (>=>) :: (a -> m b) -> (b -> m c) -> a -> m c
    public static func kleisli(
        _ fn1: @escaping @Sendable (Double) -> Vector,
        _ fn2: @escaping @Sendable (Double) -> Vector
    ) -> @Sendable (Double) -> Vector {
        { x in Vector(fn1(x).storage.flatMap { fn2($0).storage }) }
    }
}
