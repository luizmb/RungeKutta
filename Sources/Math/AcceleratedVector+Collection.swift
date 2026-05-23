import RealNumber

// MARK: - Pure, non-throwing Collection ops
//
// `AcceleratedVector` inherits `Sequence.filter` / `.reduce` / `.compactMap`
// via its `RandomAccessCollection` conformance, but those signatures are
// `rethrows`. SwiftCalx's surface is throw-free by design (errors flow
// through `Result` / `DeferredTask`), so these overloads shadow the
// inherited ones to disallow throwing closures at call sites and to keep
// `filter` returning `AcceleratedVector` (not `[Double]`).

extension AcceleratedVector {
    /// Filter elements by predicate, staying in `AcceleratedVector`-land.
    /// Shadows `Sequence.filter` (which returns `[Double]`).
    public func filter(_ isIncluded: @Sendable (Double) -> Bool) -> AcceleratedVector {
        AcceleratedVector(storage.filter(isIncluded))
    }

    /// Pure, non-throwing `reduce` mirroring `Sequence.reduce` without the
    /// `rethrows` escape hatch.
    ///
    ///     reduce :: r -> (r -> Double -> r) -> AcceleratedVector -> r
    public func reduce<Result>(_ initial: Result, _ next: @Sendable (Result, Double) -> Result) -> Result {
        storage.reduce(initial, next)
    }

    /// Pure, non-throwing `compactMap` returning `[T]`. Shadows
    /// `Sequence.compactMap` for purity.
    public func compactMap<T>(_ transform: @Sendable (Double) -> T?) -> [T] {
        storage.compactMap(transform)
    }

    /// Curried `filter`. Mirrors `Array.filterM` from FP's `CoreFP`.
    ///
    ///     filter :: (a -> Bool) -> [a] -> [a]
    public static func filterM(
        _ predicate: @escaping @Sendable (Double) -> Bool
    ) -> @Sendable (AcceleratedVector) -> AcceleratedVector {
        { vector in AcceleratedVector(vector.storage.filter(predicate)) }
    }
}
