import Foundation

extension Function {
    public static func pure(_ constant: Output) -> Function<Input, Output> {
        Function { _ in constant }
    }

    public func flatMap<NewOutput>(_ transform: @escaping (Output) -> Function<Input, NewOutput>) -> Function<Input, NewOutput> {
        Function<Input, NewOutput> { input in
            transform(self(input))(input)
        }
    }

    public func flatMap<NewOutput>(_ transform: @escaping (Output) -> (Input) -> NewOutput) -> Function<Input, NewOutput> {
        Function<Input, NewOutput> { input in
            transform(self(input))(input)
        }
    }
}
