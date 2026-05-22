import RealNumber

extension AcceleratedVector {
    /// Curried version of ``mapAccelerated(_:)`` for functional composition.
    /// Mirrors `Array.fmap` from FP's `CoreFP`.
    ///
    ///     fmap :: (a -> b) -> f a -> f b
    ///
    /// `AcceleratedVector` is concretely `[Double]`, so the codomain is also `Double`
    /// and the lifted function is `(Double) -> Double`. If you want to map
    /// to a different element type, the `Collection.map` inherited from
    /// `AcceleratedVector`'s `RandomAccessCollection` conformance returns `[T]`
    /// naturally.
    public static func fmap(
        _ fn: @escaping @Sendable (Double) -> Double
    ) -> @Sendable (AcceleratedVector) -> AcceleratedVector {
        { vector in vector.mapAccelerated(fn) }
    }
}
