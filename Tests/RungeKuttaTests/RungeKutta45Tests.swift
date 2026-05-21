import Math
@testable import RungeKutta
import XCTest

final class RungeKutta45Tests: XCTestCase {
    // MARK: - Scalar exponential decay (analytic reference)

    /// `y' = −k·y`, exact `y(t) = y₀·e^{−k·t}`. The "linear" RK45 sweet spot:
    /// the integrator should adapt the step to keep error near tolerance.
    func testScalarExponentialDecay() {
        let k = 0.3
        let y0 = 5.0
        let exact: (Double) -> Double = { t in y0 * exp(-k * t) }

        let tol = 1e-8
        let trajectory = RungeKutta45.trajectory(
            from: y0,
            derivative: { _, y in -k * y },
            through: 20,
            tolerance: tol
        )

        XCTAssertEqual(trajectory.first?.time, 0)
        XCTAssertEqual(trajectory.first?.state, y0)
        XCTAssertEqual(trajectory.last?.time ?? .nan, 20, accuracy: 1e-10)

        for (t, y) in trajectory {
            // Allow the per-step error to accumulate over the integration: a factor
            // of (final time / tolerance) is generous but bounds the worst case.
            XCTAssertEqual(y, exact(t), accuracy: max(1e-6, tol * 1_000), "at t=\(t)")
        }
    }

    // MARK: - Vector harmonic oscillator (analytic reference)

    /// `d²x/dt² = -ω²·x`, written as the coupled first-order system
    /// `y = [x, x'], dy/dt = [x', −ω²·x]`. Exact closed form
    /// `x(t) = cos(ω·t), x'(t) = −ω·sin(ω·t)`. RK45 should hit the analytic
    /// values to roughly the tolerance accumulated over many periods.
    func testHarmonicOscillator() throws {
        let omega = 2.0
        let exact: (Double) -> [Double] = { t in
            [cos(omega * t), -omega * sin(omega * t)]
        }

        let derivative: @Sendable (Double, [Double]) -> [Double] = { _, y in
            [y[1], -omega * omega * y[0]]
        }

        let trajectory = RungeKutta45.trajectory(
            from: [1.0, 0.0],
            derivative: derivative,
            through: 10,
            tolerance: 1e-8
        )

        XCTAssertEqual(trajectory.first?.state, [1.0, 0.0])
        XCTAssertEqual(trajectory.last?.time ?? .nan, 10, accuracy: 1e-10)

        // Sample several intermediate points; tolerance loosens over time
        // because per-step errors accumulate. Over ~3 periods (10 / π) that
        // accumulation is small for tol=1e-8.
        for t in stride(from: 0, through: 10, by: 1) {
            // Find the integrator's nearest accepted time and compare.
            let nearest = try XCTUnwrap(trajectory.min(by: { abs($0.time - Double(t)) < abs($1.time - Double(t)) }))
            let expected = exact(nearest.time)
            for i in 0 ..< 2 {
                XCTAssertEqual(
                    nearest.state[i],
                    expected[i],
                    accuracy: 1e-5,
                    "at t=\(nearest.time), component \(i)"
                )
            }
        }
    }

    // MARK: - Linear coupled system (matches Birchall-style biokinetic shape)

    /// Two-compartment cascade: `A → B → ∅` with rate constant `k = 0.1/day`.
    /// `dA/dt = −k·A, dB/dt = k·A − k·B`. Initial `[A, B] = [1, 0]`.
    /// Exact solution: `A(t) = e^{−k·t}`, `B(t) = k·t·e^{−k·t}`. This is the
    /// linear ODE shape that biokinetic compartmental models live in.
    func testTwoCompartmentCascade() throws {
        let k = 0.1
        let exact: (Double) -> [Double] = { t in
            let decay = exp(-k * t)
            return [decay, k * t * decay]
        }

        let derivative: @Sendable (Double, [Double]) -> [Double] = { _, y in
            [-k * y[0], k * y[0] - k * y[1]]
        }

        let trajectory = RungeKutta45.trajectory(
            from: [1.0, 0.0],
            derivative: derivative,
            through: 50,
            tolerance: 1e-8
        )

        XCTAssertEqual(trajectory.last?.time ?? .nan, 50, accuracy: 1e-10)

        // Spot-check at days {1, 5, 10, 25, 50}.
        for day in [1.0, 5.0, 10.0, 25.0, 50.0] {
            let nearest = try XCTUnwrap(trajectory.min(by: { abs($0.time - day) < abs($1.time - day) }))
            let expected = exact(nearest.time)
            XCTAssertEqual(nearest.state[0], expected[0], accuracy: 1e-6, "A at t=\(nearest.time)")
            XCTAssertEqual(nearest.state[1], expected[1], accuracy: 1e-6, "B at t=\(nearest.time)")
        }
    }

    // MARK: - Adaptivity sanity check

    /// On a smooth problem, the adaptive integrator should take noticeably fewer
    /// steps than the equivalent fixed-step RK4 to reach the same end time.
    /// This is the practical reason to prefer RK45 over RK4 for smooth ODEs.
    func testAdaptiveFewerStepsThanFixed() {
        let k = 0.3
        let trajectory = RungeKutta45.trajectory(
            from: 5.0,
            derivative: { _, y in -k * y },
            through: 20,
            tolerance: 1e-6
        )

        // RK4 fixed step of 0.05 would produce 401 points (0, 0.05, …, 20).
        // RK45 with tol=1e-6 on a smooth exponential should comfortably use
        // far fewer accepted steps.
        XCTAssertLessThan(trajectory.count, 100, "expected adaptive to be << fixed-step")
        XCTAssertGreaterThan(trajectory.count, 5, "expected at least a handful of steps")
    }

    // MARK: - Final time landing

    /// The integrator must land exactly on `through`, even when adaptive steps
    /// would overshoot — the trajectory driver shrinks the final step.
    func testLandsExactlyOnEndTime() {
        let end = 13.7
        let trajectory = RungeKutta45.trajectory(
            from: 1.0,
            derivative: { _, y in -0.5 * y },
            through: end,
            tolerance: 1e-6
        )
        XCTAssertEqual(trajectory.last?.time ?? .nan, end, accuracy: 1e-12)
    }

    // MARK: - Empty span returns just the initial point

    func testZeroSpan() {
        let trajectory = RungeKutta45.trajectory(
            from: 42.0,
            derivative: { _, y in y },
            startingAt: 5.0,
            through: 5.0,
            tolerance: 1e-6
        )
        XCTAssertEqual(trajectory.count, 1)
        XCTAssertEqual(trajectory.first?.time, 5.0)
        XCTAssertEqual(trajectory.first?.state, 42.0)
    }

    // MARK: - Tighter tolerance ⇒ more steps

    func testTighterToleranceProducesMoreSteps() {
        let derivative: @Sendable (Double, Double) -> Double = { _, y in -0.3 * y }
        let loose = RungeKutta45.trajectory(
            from: 5.0,
            derivative: derivative,
            through: 20,
            tolerance: 1e-3
        )
        let tight = RungeKutta45.trajectory(
            from: 5.0,
            derivative: derivative,
            through: 20,
            tolerance: 1e-10
        )
        XCTAssertGreaterThan(tight.count, loose.count)
    }
}
