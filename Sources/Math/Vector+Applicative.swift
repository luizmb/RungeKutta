import RealNumber

extension Vector {
    /// Lift a binary `(Double, Double) -> Double` into an operation on
    /// `Vector`s by Cartesian product. Mirrors `Array.liftA2` from FP's
    /// `CoreFP` (which uses `flatMap` + `map` for the non-determinism
    /// monad's Applicative).
    ///
    ///     liftA2 :: (a -> b -> c) -> [a] -> [b] -> [c]
    ///
    /// Note the Cartesian semantics: result length is `lhs.count * rhs.count`,
    /// not elementwise. For elementwise arithmetic prefer ``Vector/+(_:_:)``
    /// and friends.
    public static func liftA2(
        _ fn: @escaping @Sendable (Double, Double) -> Double
    ) -> @Sendable (Vector, Vector) -> Vector {
        { lhs, rhs in
            Vector(lhs.storage.flatMap { a in
                rhs.storage.map { b in fn(a, b) }
            })
        }
    }

    /// Applicative apply — applies a vector of functions to a vector of
    /// values via Cartesian product. Mirrors `Array.apply` from FP's
    /// `CoreFP`.
    ///
    ///     (<*>) :: [a -> b] -> [a] -> [b]
    public static func apply(
        _ functions: [@Sendable (Double) -> Double],
        _ values: Vector
    ) -> Vector {
        Vector(functions.flatMap { f in values.storage.map(f) })
    }
}
