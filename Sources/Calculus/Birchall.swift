import Foundation
import Math
import RealNumber

/// Birchall's scaling-and-squaring algorithm for the matrix exponential `e^A`.
///
/// Named for **A. Birchall**'s 1986 paper *"A microcomputer algorithm for solving
/// compartmental models involving radionuclide transformations"* (Health Physics 50,
/// pp. 389–397), which adapted the classical scaling-and-squaring exp method for
/// efficient evaluation in radiation dosimetry where the matrix `A` encodes transfer
/// rates between body compartments plus radioactive decay.
///
/// ## Why scaling-and-squaring?
///
/// The straight Taylor series `e^A = I + A + A²/2! + A³/3! + …` converges for any
/// square matrix in theory. **In floating-point** it's a disaster for matrices with
/// large-magnitude entries: terms grow huge before the factorial finally tames them,
/// and cancellation in `sum + term - …` destroys accuracy.
///
/// The trick: exploit the identity `e^A = (e^(A / 2^k))^(2^k)`. By dividing `A` by a
/// large enough power of 2, we shrink the entries until the Taylor series converges
/// cleanly. Then we square `k` times to recover `e^A`. Each squaring is one matrix
/// multiplication — far cheaper than the lost accuracy of an unscaled series.
///
/// ## The algorithm
///
/// Given a square matrix `A`:
///
/// 1. **Choose the scaling power `k`** so that the scaled matrix `A / 2^k` is "small"
///    enough for safe Taylor evaluation. Birchall uses the heuristic
///    `−min(diag(A)) / 2^k < 0.2` — squeeze the most-negative diagonal entry down
///    below `0.2`. (Diagonals are the relevant scale because the diagonal carries
///    `−λ − Σ outflow` in a compartmental model, dominating the spectrum.)
/// 2. **Form the scaled matrix** `Aₛ = A / 2^k`.
/// 3. **Taylor-expand `e^Aₛ`** via ``Taylor/exponential(of:tolerance:maxIterations:)``.
/// 4. **Square `k` times** via ``Math/Matrix/squared(times:)`` to recover
///    `e^A = (e^Aₛ)^(2^k)`.
///
/// ## Accuracy
///
/// With the default tolerance `1e-10` and the `< 0.2` scaling threshold, Birchall is
/// accurate to roughly `1e-12` per element on a wide range of dosimetry-style matrices
/// (small to moderate dimension, mostly negative diagonals). The Swift port of the
/// ICRP Uranium-238 biokinetic model agrees with the original C# reference to
/// `1e-12` over 1000 days of integration — see `UraniumGoldenTests` in the
/// `MultiCompartmentModel` consumer.
///
/// References:
/// - Birchall, A. (1986). *A microcomputer algorithm for solving compartmental models
///   involving radionuclide transformations*. Health Physics 50(3): 389–397.
/// - Moler & Van Loan (2003). *Nineteen Dubious Ways to Compute the Exponential of a
///   Matrix, Twenty-Five Years Later*. SIAM Review 45(1): 3–49. §3 covers
///   scaling-and-squaring as method 3.
/// - https://en.wikipedia.org/wiki/Matrix_exponential#Scaling_and_squaring
public enum Birchall {
    /// Computes `e^A` via scaling-and-squaring. See the type-level documentation for
    /// the algorithm and references.
    public static func matrixExponential(
        _ A: Matrix<Double>,
        tolerance: Double = 1e-10,
        maxIterations: Int = 10_000
    ) -> Matrix<Double> {
        let minDiagonal = (0 ..< A.rows).map { A[$0, $0] }.min() ?? 0
        let k = scalingPower(forMinDiagonal: minDiagonal)
        let scaled = (1 / exp(log(2) * Double(k))) * A
        let exponentiated = Taylor.exponential(of: scaled, tolerance: tolerance, maxIterations: maxIterations)
        return exponentiated.squared(times: k)
    }

    /// Smallest non-negative `k` such that `−minDiagonal / 2^k < threshold`.
    ///
    /// Birchall's heuristic chooses the scaling power so the most-negative diagonal
    /// entry of the scaled matrix is small enough (`< 0.2` by default) that the Taylor
    /// series converges quickly without catastrophic cancellation. For
    /// `minDiagonal ≥ 0`, returns `0` (no scaling needed).
    public static func scalingPower(
        forMinDiagonal minDiagonal: Double,
        threshold: Double = 0.2
    ) -> Int {
        (0 ... 1000).first { -minDiagonal / exp(log(2) * Double($0)) < threshold } ?? 1000
    }
}
