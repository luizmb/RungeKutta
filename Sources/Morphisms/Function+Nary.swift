import Foundation

public typealias Function2<I1, I2, Output> = Function<(I1, I2), Output>

extension Function2 {
    public init<I1, I2>(_ fn: @escaping (I1, I2) -> Output) where Input == (I1, I2) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1)
        }
    }

    public func callAsFunction<I1, I2>(_ x1: I1, _ x2: I2) -> Output where Input == (I1, I2) {
        self((x1, x2))
    }

    public func partialApply<I1, I2>(_ x1: I1) -> Function<I2, Output> where Input == (I1, I2) {
        .init { x2 in
            self((x1, x2))
        }
    }

    public func curry<I1, I2>() -> Function<I1, Function<I2, Output>> where Input == (I1, I2) {
        .init { x1 in
            .init { x2 in
                self((x1, x2))
            }
        }
    }
}

public typealias Function3<I1, I2, I3, Output> = Function<(I1, I2, I3), Output>

extension Function3 {
    public init<I1, I2, I3>(_ fn: @escaping (I1, I2, I3) -> Output) where Input == (I1, I2, I3) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1, inputs.2)
        }
    }

    public func callAsFunction<I1, I2, I3>(_ x1: I1, _ x2: I2, _ x3: I3) -> Output where Input == (I1, I2, I3) {
        self((x1, x2, x3))
    }

    public func partialApply<I1, I2, I3>(_ x1: I1) -> Function2<I2, I3, Output> where Input == (I1, I2, I3) {
        .init { (x2, x3) in
            self((x1, x2, x3))
        }
    }

    public func curry<I1, I2, I3>() -> Function<I1, Function2<I2, I3, Output>> where Input == (I1, I2, I3) {
        .init { x1 in
            .init { (x2, x3) in
                self((x1, x2, x3))
            }
        }
    }
}

public typealias Function4<I1, I2, I3, I4, Output> = Function<(I1, I2, I3, I4), Output>

extension Function4 {
    public init<I1, I2, I3, I4>(_ fn: @escaping (I1, I2, I3, I4) -> Output) where Input == (I1, I2, I3, I4) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1, inputs.2, inputs.3)
        }
    }

    public func callAsFunction<I1, I2, I3, I4>(_ x1: I1, _ x2: I2, _ x3: I3, _ x4: I4) -> Output where Input == (I1, I2, I3, I4) {
        self((x1, x2, x3, x4))
    }

    public func partialApply<I1, I2, I3, I4>(_ x1: I1) -> Function3<I2, I3, I4, Output> where Input == (I1, I2, I3, I4) {
        .init { (x2, x3, x4) in
            self((x1, x2, x3, x4))
        }
    }

    public func curry<I1, I2, I3, I4>() -> Function<I1, Function3<I2, I3, I4, Output>> where Input == (I1, I2, I3, I4) {
        .init { x1 in
            .init { (x2, x3, x4) in
                self((x1, x2, x3, x4))
            }
        }
    }
}

public typealias Function5<I1, I2, I3, I4, I5, Output> = Function<(I1, I2, I3, I4, I5), Output>

extension Function5 {
    public init<I1, I2, I3, I4, I5>(_ fn: @escaping (I1, I2, I3, I4, I5) -> Output) where Input == (I1, I2, I3, I4, I5) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1, inputs.2, inputs.3, inputs.4)
        }
    }

    public func callAsFunction<I1, I2, I3, I4, I5>(_ x1: I1, _ x2: I2, _ x3: I3, _ x4: I4, _ x5: I5) -> Output where Input == (I1, I2, I3, I4, I5) {
        self((x1, x2, x3, x4, x5))
    }

    public func partialApply<I1, I2, I3, I4, I5>(_ x1: I1) -> Function4<I2, I3, I4, I5, Output> where Input == (I1, I2, I3, I4, I5) {
        .init { (x2, x3, x4, x5) in
            self((x1, x2, x3, x4, x5))
        }
    }

    public func curry<I1, I2, I3, I4, I5>() -> Function<I1, Function4<I2, I3, I4, I5, Output>> where Input == (I1, I2, I3, I4, I5) {
        .init { x1 in
            .init { (x2, x3, x4, x5) in
                self((x1, x2, x3, x4, x5))
            }
        }
    }
}

public typealias Function6<I1, I2, I3, I4, I5, Í6, Output> = Function<(I1, I2, I3, I4, I5, Í6), Output>

extension Function6 {
    public init<I1, I2, I3, I4, I5, Í6>(_ fn: @escaping (I1, I2, I3, I4, I5, Í6) -> Output) where Input == (I1, I2, I3, I4, I5, Í6) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1, inputs.2, inputs.3, inputs.4, inputs.5)
        }
    }

    public func callAsFunction<I1, I2, I3, I4, I5, Í6>(_ x1: I1, _ x2: I2, _ x3: I3, _ x4: I4, _ x5: I5, _ x6: Í6) -> Output where Input == (I1, I2, I3, I4, I5, Í6) {
        self((x1, x2, x3, x4, x5, x6))
    }

    public func partialApply<I1, I2, I3, I4, I5, I6>(_ x1: I1) -> Function5<I2, I3, I4, I5, I6, Output> where Input == (I1, I2, I3, I4, I5, I6) {
        .init { (x2, x3, x4, x5, x6) in
            self((x1, x2, x3, x4, x5, x6))
        }
    }

    public func curry<I1, I2, I3, I4, I5, I6>() -> Function<I1, Function5<I2, I3, I4, I5, I6, Output>> where Input == (I1, I2, I3, I4, I5, I6) {
        .init { x1 in
            .init { (x2, x3, x4, x5, x6) in
                self((x1, x2, x3, x4, x5, x6))
            }
        }
    }
}

public typealias Function7<I1, I2, I3, I4, I5, Í6, eI7, Output> = Function<(I1, I2, I3, I4, I5, Í6, eI7), Output>

extension Function7 {
    public init<I1, I2, I3, I4, I5, Í6, eI7>(_ fn: @escaping (I1, I2, I3, I4, I5, Í6, eI7) -> Output) where Input == (I1, I2, I3, I4, I5, Í6, eI7) {
        self.fn = { inputs in
            fn(inputs.0, inputs.1, inputs.2, inputs.3, inputs.4, inputs.5, inputs.6)
        }
    }

    public func callAsFunction<I1, I2, I3, I4, I5, Í6, eI7>(_ x1: I1, _ x2: I2, _ x3: I3, _ x4: I4, _ x5: I5, _ x6: Í6, _ x7: eI7) -> Output where Input == (I1, I2, I3, I4, I5, Í6, eI7) {
        self((x1, x2, x3, x4, x5, x6, x7))
    }

    public func partialApply<I1, I2, I3, I4, I5, I6, I7>(_ x1: I1) -> Function6<I2, I3, I4, I5, I6, I7, Output> where Input == (I1, I2, I3, I4, I5, I6, I7) {
        .init { (x2, x3, x4, x5, x6, x7) in
            self((x1, x2, x3, x4, x5, x6, x7))
        }
    }

    public func curry<I1, I2, I3, I4, I5, I6, I7>() -> Function<I1, Function6<I2, I3, I4, I5, I6, I7, Output>> where Input == (I1, I2, I3, I4, I5, I6, I7) {
        .init { x1 in
            .init { (x2, x3, x4, x5, x6, x7) in
                self((x1, x2, x3, x4, x5, x6, x7))
            }
        }
    }
}
