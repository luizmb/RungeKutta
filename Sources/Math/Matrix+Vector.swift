import RealNumber

extension Matrix where Scalar == Double {
    /// `Matrix · Vector` — same compute as ``apply(to:)-9wzs`` for `[Double]`,
    /// but takes and returns ``Vector`` so consumers in `Vector`-land
    /// (typically the derivative function passed to a generic-over-VectorState
    /// solver) don't have to round-trip through `[Double]` explicitly.
    ///
    /// Zero overhead vs the `[Double]` overload — the `Vector` wrapper is a
    /// thin struct around the COW backing array; `vector.storage` shares the
    /// buffer, and `Vector(...)` wraps the result without copying.
    public func apply(to vector: Vector) -> Vector {
        Vector(apply(to: vector.storage))
    }
}
