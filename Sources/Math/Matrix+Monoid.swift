import RealNumber

extension Matrix {
    /// The additive monoid over `rows × columns` matrices: identity is the zero
    /// matrix of that shape, combine is elementwise `+`.
    ///
    /// Associative because matrix addition is associative; both-sided identity
    /// because adding the zero matrix changes nothing.
    public static func additiveMonoid(rows: Int, columns: Int) -> MonoidWitness<Matrix> {
        MonoidWitness(
            identity: Matrix(rows: rows, columns: columns, storage: Array(repeating: 0, count: rows * columns)),
            combine: +
        )
    }

    /// The multiplicative monoid over `n × n` square matrices: identity is `Iₙ`,
    /// combine is matrix multiplication.
    ///
    /// This is the algebraic content of the *matrix-exponential semigroup* used by
    /// Birchall: `exp((s + t) · A) = exp(s · A) · exp(t · A)`. Equivalently, for a
    /// fixed `Δt` and `B = exp(Δt · A)`, the trajectory under the linear ODE
    /// `dy/dt = A · y` becomes `y(n · Δt) = Bⁿ · y₀`. The semigroup law is what
    /// makes that valid; this witness packages it.
    ///
    /// For the *iterated action* on a starting vector (rather than matrix powers
    /// themselves), prefer ``actions(on:count:)`` — it does the same job in
    /// `O(n²) per step` mat-vecs instead of `O(n³) per step` mat-mats.
    public static func multiplicativeMonoid(size n: Int) -> MonoidWitness<Matrix> {
        MonoidWitness(identity: .identity(size: n), combine: *)
    }
}
