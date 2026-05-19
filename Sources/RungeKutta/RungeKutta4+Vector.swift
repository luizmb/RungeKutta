import RealNumber

extension RungeKutta4 {
    /// Vector-state RK4. The derivative depends on the whole state vector at each substep,
    /// which is required for coupled ODE systems like multi-compartment biokinetic models.
    ///
    /// Returns a step function `(t, y, Δt) → Δy`. Like the scalar overload, the returned
    /// Δ is a *pure delta* — callers add `y + Δy` to obtain the next state.
    public static func rk4<State: VectorState>(
        _ fn: @escaping (State.Scalar, State) -> State
    ) -> (/* t */ State.Scalar, /* y */ State, /* Δt */ State.Scalar) -> /* Δy */ State {
        { t, y, Δt in
            let two: State.Scalar = 2
            let six: State.Scalar = 6
            let half = Δt / two
            let k1 = fn(t,        y)
            let k2 = fn(t + half, y + half * k1)
            let k3 = fn(t + half, y + half * k2)
            let k4 = fn(t + Δt,   y +   Δt * k3)
            let weighted = k1 + two * k2 + two * k3 + k4
            return (Δt / six) * weighted
        }
    }

    /// Reduce-shaped helper that appends the next `(time, state)` pair to the trajectory.
    /// Use as the closure passed to `stride(...).reduce(...)`.
    public static func calculateNextState<State: VectorState>(
        Δt: State.Scalar,
        stepCalculator: @escaping (State.Scalar, State, State.Scalar) -> State
    ) -> (
        [(time: State.Scalar, state: State)],
        State.Scalar
    ) -> [(time: State.Scalar, state: State)] {
        { points, _ in
            guard let last = points.last else { return [] }
            let Δy = stepCalculator(last.time, last.state, Δt)
            return points + [(time: last.time + Δt, state: last.state + Δy)]
        }
    }
}
