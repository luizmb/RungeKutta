import RealNumber

/// A first-class, hardware-acceleration-friendly numeric vector of `Double`.
///
/// `Vector` is the opt-in fast state type for ``RungeKutta4``, ``RungeKutta45``,
/// and any other generic-over-``VectorState`` solver. Wrap your `[Double]` once
/// at the entry point and every per-stage `+` / `*` along the integration
/// trajectory routes through hand-tuned BLAS / vDSP kernels on Apple
/// platforms via the protocol witness — without runtime type checks or
/// specialised overloads on the solver itself.
///
/// ## Why a wrapper around `[Double]`?
///
/// `Array<Double>` already conforms to ``VectorState``, but Swift selects the
/// protocol witness for `+` and scalar `*` at the conformance site — which
/// uses the generic, scalar `zip(...).map(+)` implementation. There's no way
/// to "specialise" that witness for `[Double]` without breaking the protocol
/// rules. `Vector` sidesteps the problem by being its own concrete type
/// whose own witness for `+` and `*` is the optimised vDSP path. Generic
/// solver code dispatches naturally through the witness; no specialisation
/// overloads, no runtime checks, no `.+` operator gymnastics.
///
/// ## When `Vector` doesn't matter
///
/// On non-Apple builds (Linux / WASM) and on Apple builds with the
/// `-D SWIFTCALX_NO_ACCELERATE` flag, `Vector`'s `+` / `*` fall back to the
/// same scalar Swift implementation that `[Double]` uses. No win; no loss.
/// The performance edge is specifically vDSP.
///
/// ## Migration cost
///
/// One line at the entry point and (importantly) one line in the derivative
/// function, both zero-allocation:
///
/// ```swift
/// // Before — [Double] state, scalar per-stage ops
/// let trajectory = RungeKutta45.trajectory(
///     at: outputTimes,
///     from: [1.0, 0.0],
///     derivative: { _, y in A.apply(to: y) }
/// )
///
/// // After — Vector state, vDSP per-stage ops
/// let trajectory = RungeKutta45.trajectory(
///     at: outputTimes,
///     from: [1.0, 0.0].asVector,
///     derivative: { _, y in A.apply(to: y) }   // returns Vector via the bridge overload
/// )
/// ```
///
/// `Vector` is a thin struct around `[Double]` — `Vector(myArray)` and
/// `myArray.asVector` share the array's underlying COW buffer, no copy.
public struct Vector: Sendable {
    /// The underlying `[Double]` buffer. Same shape and indexing as a flat
    /// row of `Matrix`; safe to hand back out for interop.
    public let storage: [Double]

    public init(_ storage: [Double]) {
        self.storage = storage
    }

    /// Convenience initialiser for variadic Double values: `Vector(1.0, 2.0, 3.0)`.
    public init(_ elements: Double...) {
        self.storage = elements
    }

    public var count: Int { storage.count }
    public var isEmpty: Bool { storage.isEmpty }
}

// MARK: - Conformances

extension Vector: Equatable {}
extension Vector: Hashable {}

extension Vector: CustomStringConvertible {
    public var description: String { "Vector(\(storage))" }
}

extension Vector: CustomDebugStringConvertible {
    public var debugDescription: String { "Vector(\(storage.debugDescription))" }
}

// MARK: - Collection support (so for-each, map, filter, reduce, indexing all work)

extension Vector: RandomAccessCollection {
    public typealias Element = Double
    public typealias Index = Int

    public var startIndex: Int { storage.startIndex }
    public var endIndex: Int { storage.endIndex }
    public func index(after i: Int) -> Int { storage.index(after: i) }
    public func index(before i: Int) -> Int { storage.index(before: i) }
    public subscript(position: Int) -> Double { storage[position] }
}

// MARK: - Type-preserving map

extension Vector {
    /// Element-wise transformation that stays in `Vector`-land. Use when you
    /// want a `Vector` back; the inherited Collection `map` returns `[T]`
    /// (and naturally `[Double]` when `T == Double`).
    public func mapVector(_ transform: (Double) -> Double) -> Vector {
        Vector(storage.map(transform))
    }
}

// MARK: - Array bridge

extension Array where Element == Double {
    /// Wrap `self` as a `Vector` without copying. Same COW buffer.
    public var asVector: Vector { Vector(self) }
}
