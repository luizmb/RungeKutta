import RealNumber

extension Vector {
    /// Curried version of ``mapVector(_:)`` for functional composition.
    /// Mirrors `Array.fmap` from FP's `CoreFP`.
    ///
    ///     fmap :: (a -> b) -> f a -> f b
    ///
    /// `Vector` is concretely `[Double]`, so the codomain is also `Double`
    /// and the lifted function is `(Double) -> Double`. If you want to map
    /// to a different element type, the `Collection.map` inherited from
    /// `Vector`'s `RandomAccessCollection` conformance returns `[T]`
    /// naturally.
    public static func fmap(
        _ fn: @escaping @Sendable (Double) -> Double
    ) -> @Sendable (Vector) -> Vector {
        { vector in vector.mapVector(fn) }
    }
}
