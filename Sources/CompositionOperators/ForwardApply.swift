import Foundation
import Morphisms

/*
 Pipe forward application operator
 |>

 Apply function
 - Left: value a: A
 - Right: function A to B
 - Return: value b: B

 * left associativity
 * precedence group: Forward Application
 */
infix operator |>: ForwardApplication
precedencegroup ForwardApplication {
    associativity: left
    higherThan: Apply
}

// Swift Function, n-ary
public func |> <Input, Output>(a: Input, fn: @escaping (Input) -> Output) -> Output {
    fn(a)
}

public func |> <I1, I2, Output>(a: I1, fn: @escaping (I1, I2) -> Output) -> Function<I2, Output> {
    (^fn).partialApply(a)
}

public func |> <I1, I2, I3, Output>(a: I1, fn: @escaping (I1, I2, I3) -> Output) -> Function2<I2, I3, Output> {
    (^fn).partialApply(a)
}

public func |> <I1, I2, I3, I4, Output>(a: I1, fn: @escaping (I1, I2, I3, I4) -> Output) -> Function3<I2, I3, I4, Output> {
    (^fn).partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, Output>(a: I1, fn: @escaping (I1, I2, I3, I4, I5) -> Output) -> Function4<I2, I3, I4, I5, Output> {
    (^fn).partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, I6, Output>(a: I1, fn: @escaping (I1, I2, I3, I4, I5, I6) -> Output) -> Function5<I2, I3, I4, I5, I6, Output> {
    (^fn).partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, I6, I7, Output>(a: I1, fn: @escaping (I1, I2, I3, I4, I5, I6, I7) -> Output) -> Function6<I2, I3, I4, I5, I6, I7, Output> {
    (^fn).partialApply(a)
}

// Function box, n-ary
public func |> <Input, Output>(a: Input, fn: Function<Input, Output>) -> Output {
    fn(a)
}

public func |> <I1, I2, Output>(a: I1, fn: Function2<I1, I2, Output>) -> Function<I2, Output> {
    fn.partialApply(a)
}

public func |> <I1, I2, I3, Output>(a: I1, fn: Function3<I1, I2, I3, Output>) -> Function2<I2, I3, Output> {
    fn.partialApply(a)
}

public func |> <I1, I2, I3, I4, Output>(a: I1, fn: Function4<I1, I2, I3, I4, Output>) -> Function3<I2, I3, I4, Output> {
    fn.partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, Output>(a: I1, fn: Function5<I1, I2, I3, I4, I5, Output>) -> Function4<I2, I3, I4, I5, Output> {
    fn.partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, I6, Output>(a: I1, fn: Function6<I1, I2, I3, I4, I5, I6, Output>) -> Function5<I2, I3, I4, I5, I6, Output> {
    fn.partialApply(a)
}

public func |> <I1, I2, I3, I4, I5, I6, I7, Output>(a: I1, fn: Function7<I1, I2, I3, I4, I5, I6, I7, Output>) -> Function6<I2, I3, I4, I5, I6, I7, Output> {
    fn.partialApply(a)
}

// Swift Function, functors
public func |> <Input, Output>(a: [Input], fn: @escaping (Input) -> Output) -> [Output] {
    a.map(fn)
}

public func |> <Input, Output>(a: Input?, fn: @escaping (Input) -> Output) -> Output? {
    a.map(fn)
}

public func |> <Input, Output, E: Error>(a: Result<Input, E>, fn: @escaping (Input) -> Output) -> Result<Output, E> {
    a.map(fn)
}

public func |> <Input, Output>(a: Input, fn: @escaping (Input) throws -> Output) -> Result<Output, Error> {
    Result { try fn(a) }
}

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func |> <P: Publisher, Output>(a: P, fn: @escaping (P.Output) -> Output) -> any Publisher<Output, P.Failure> {
    a.map(fn)
}
#endif

// Function box, functors
public func |> <Input, Output>(a: [Input], fn: Function<Input, Output>) -> [Output] {
    a.map(fn.callAsFunction)
}

public func |> <Input, Output>(a: Input?, fn: Function<Input, Output>) -> Output? {
    a.map(fn.callAsFunction)
}

public func |> <Input, Output, E: Error>(a: Result<Input, E>, fn: Function<Input, Output>) -> Result<Output, E> {
    a.map(fn.callAsFunction)
}

public func |> <Input, Output, E: Error>(a: Input, fn: Function<Input, Result<Output, E>>) -> Result<Output, E> {
    fn(a)
}

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func |> <P: Publisher, Output>(a: P, fn: Function<P.Output, Output>) -> any Publisher<Output, P.Failure> {
    a.map(fn.callAsFunction)
}
#endif

