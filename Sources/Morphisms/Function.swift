import Foundation

public struct Function<Input, Output> {
    let fn: (Input) -> Output

    public init(_ fn: @escaping (Input) -> Output) {
        self.fn = fn
    }

    public func callAsFunction(_ x: Input) -> Output {
        fn(x)
    }
}
