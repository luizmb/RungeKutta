import Foundation

extension Function {
    public func contramap<NewInput>(_ transform: @escaping (NewInput) -> Input) -> Function<NewInput, Output> {
        Function<NewInput, Output> { newInput in
            self(transform(newInput))
        }
    }

    public func map<NewOutput>(_ transform: @escaping (Output) -> NewOutput) -> Function<Input, NewOutput> {
        Function<Input, NewOutput> { input in
            transform(self(input))
        }
    }
}
