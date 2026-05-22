import RealNumber

extension AcceleratedVector {
    /// Curried version of `flatMap`-into-`AcceleratedVector` for functional composition.
    /// Mirrors `Array.bind` from FP's `CoreFP`.
    ///
    ///     (>>=) :: m a -> (a -> m b) -> m b
    ///
    /// Composes per-element transformations that themselves produce vectors,
    /// flattening the result. The element type is fixed to `Double` (both
    /// input and output) because `AcceleratedVector` is concretely `[Double]`.
    public static func bind(
        _ fn: @escaping @Sendable (Double) -> AcceleratedVector
    ) -> @Sendable (AcceleratedVector) -> AcceleratedVector {
        { vector in AcceleratedVector(vector.storage.flatMap { fn($0).storage }) }
    }

    /// Kleisli composition (left-to-right) over `AcceleratedVector`.
    /// Mirrors `Array.kleisli` from FP's `CoreFP`.
    ///
    ///     (>=>) :: (a -> m b) -> (b -> m c) -> a -> m c
    public static func kleisli(
        _ fn1: @escaping @Sendable (Double) -> AcceleratedVector,
        _ fn2: @escaping @Sendable (Double) -> AcceleratedVector
    ) -> @Sendable (Double) -> AcceleratedVector {
        { x in AcceleratedVector(fn1(x).storage.flatMap { fn2($0).storage }) }
    }
}
