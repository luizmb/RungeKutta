import RealNumber

extension AcceleratedVector {
    /// Pure, non-throwing `flatMap` returning `[T]`. Shadows
    /// `Sequence.flatMap`'s `rethrows` form for purity (use `Result` /
    /// `DeferredTask` for error handling).
    ///
    ///     flatMap :: AcceleratedVector -> (Double -> [b]) -> [b]
    public func flatMap<T>(_ transform: @Sendable (Double) -> [T]) -> [T] {
        storage.flatMap(transform)
    }

    /// Type-preserving `flatMap` for the `(Double) -> AcceleratedVector` case
    /// — concatenates the resulting vectors and stays inside
    /// `AcceleratedVector`-land.
    public func flatMap(_ transform: @Sendable (Double) -> AcceleratedVector) -> AcceleratedVector {
        AcceleratedVector(storage.flatMap { transform($0).storage })
    }

    /// Curried, generic `bind`. Mirrors `Array.bind` from FP's `CoreFP`.
    ///
    ///     (>>=) :: m a -> (a -> m b) -> m b
    public static func bind<A1>(
        _ fn: @escaping @Sendable (Double) -> [A1]
    ) -> @Sendable (AcceleratedVector) -> [A1] {
        { vector in vector.storage.flatMap(fn) }
    }

    /// Type-preserving curried `bind` for the `(Double) -> AcceleratedVector`
    /// case — keeps the result inside `AcceleratedVector`-land.
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

    /// Kleisli composition (right-to-left). Mirrors `Array.kleisliBack`.
    ///
    ///     (<=<) :: (b -> m c) -> (a -> m b) -> a -> m c
    public static func kleisliBack(
        _ fn2: @escaping @Sendable (Double) -> AcceleratedVector,
        _ fn1: @escaping @Sendable (Double) -> AcceleratedVector
    ) -> @Sendable (Double) -> AcceleratedVector {
        { x in AcceleratedVector(fn1(x).storage.flatMap { fn2($0).storage }) }
    }

    /// Alternative — vector concatenation. Mirrors `Array.alt`.
    ///
    ///     (<|>) :: [a] -> [a] -> [a]
    ///
    /// Equivalent to ``Semigroup.combine(_:_:)`` for `AcceleratedVector`.
    public static func alt(_ lhs: AcceleratedVector, _ rhs: @autoclosure () -> AcceleratedVector) -> AcceleratedVector {
        combine(lhs, rhs())
    }

    /// Concatenates an array of vectors into one. Mirrors `Array.concat`.
    ///
    ///     concat :: [[a]] -> [a]
    public static func concat(_ vectors: [AcceleratedVector]) -> AcceleratedVector {
        AcceleratedVector(vectors.flatMap(\.storage))
    }

    /// Monadic join — flattens a vector of vectors. Mirrors `Array.join`.
    ///
    ///     join :: m (m a) -> m a
    public static func join(_ nested: [AcceleratedVector]) -> AcceleratedVector {
        AcceleratedVector(nested.flatMap(\.storage))
    }

    /// Discards the values, keeping only the structure. Mirrors `Array.void`.
    ///
    ///     void :: m a -> m ()
    public func void() -> [Void] {
        storage.map { _ in () }
    }
}
