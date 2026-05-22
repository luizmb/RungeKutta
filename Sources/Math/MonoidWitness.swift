import CoreFP
import RealNumber

/// A monoid expressed as runtime data rather than as a protocol conformance.
///
/// `MonoidWitness` is the **witness pattern** applied to ``CoreFP/Monoid``: instead
/// of "is `T` a monoid?", you ask "*which* monoid over `T`?". Pick or build the
/// witness you want, pass it where you need it, fold a sequence through it.
///
/// ## Why a witness instead of `Monoid` conformance?
///
/// A protocol conformance like `T: Monoid` says *the* monoid structure of `T` —
/// it has one identity (`static var identity`) and one combine operation
/// (`static func combine`). That's fine for types with a single canonical monoid
/// (e.g. `String` under concatenation), but it breaks down whenever:
///
/// 1. **The identity needs a runtime parameter.** A `Matrix<Double>` has many
///    additive identities — one per (rows, cols) shape — and many multiplicative
///    identities — one per square size. A static `identity` property can't pick
///    a shape. ``Matrix/additiveMonoid(rows:columns:)`` and
///    ``Matrix/multiplicativeMonoid(size:)`` *can* — they're factories that close
///    over the shape and return a `MonoidWitness<Matrix>`.
/// 2. **A type has more than one valid monoid.** `Double` is a monoid under
///    addition *and* under multiplication *and* under min *and* under max — all
///    canonical. FP wraps these with `NumericMonoid<Double>.Sum`,
///    `NumericMonoid<Double>.Product`, etc. The witness pattern lets the caller
///    spell which one inline without a wrapper allocation.
///
/// ## Laws (caller's responsibility to honour)
///
/// - **Associativity**: `combine(combine(a, b), c) == combine(a, combine(b, c))`.
/// - **Left identity**: `combine(identity, a) == a` for all `a`.
/// - **Right identity**: `combine(a, identity) == a` for all `a`.
///
/// If the operation only satisfies associativity (no identity at all), use the
/// raw closure — `MonoidWitness` is for monoids specifically. A future
/// `SemigroupWitness` could capture that weaker case if a use case demands it.
public struct MonoidWitness<T: Sendable>: Sendable {
    public let identity: T
    public let combine: @Sendable (T, T) -> T

    public init(identity: T, combine: @escaping @Sendable (T, T) -> T) {
        self.identity = identity
        self.combine = combine
    }

    /// Folds `value` against itself `count` times by repeated `combine`. Returns
    /// `identity` for `count == 0`, `value` for `count == 1`, `combine(value, value)`
    /// for `count == 2`, and so on.
    ///
    /// Useful for computing `aⁿ` in the monoid: matrix powers, repeated string
    /// concatenation, polynomial powers. Naïve O(n) implementation — not
    /// exponentiation-by-squaring — because the witness has no equality available
    /// to detect convergence and many monoids of interest aren't comparable.
    public func iterate(_ value: T, count: Int) -> T {
        guard count > 0 else { return identity }
        return (1 ..< count).reduce(value) { acc, _ in combine(acc, value) }
    }
}

extension Sequence where Element: Sendable {
    /// Reduces the sequence by combining elements through `witness`, starting from
    /// the witness's `identity`. The monoid equivalent of `reduce(.zero, +)`.
    ///
    /// Equivalent to `reduce(witness.identity, witness.combine)` — the named API
    /// just reads better at call sites and signals intent.
    public func reduced(using witness: MonoidWitness<Element>) -> Element {
        reduce(witness.identity, witness.combine)
    }
}
