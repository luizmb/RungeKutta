import Foundation

extension Function {
    public func apply<NewOutput>(_ wrappedFunction: Function<Input, (Output) -> NewOutput>) -> Function<Input, NewOutput> {
        Function<Input, NewOutput> { input in
            wrappedFunction(input)(self(input))
        }
    }
}

public func zip<Input, Output1, Output2>(_ a: Function<Input, Output1>, _ b: Function<Input, Output2>) -> Function<Input, (Output1, Output2)> {
    a.apply(Function { (input: Input) -> (Output1) -> (Output1, Output2) in
        { output1 in
            (output1, b(input))
        }
    })
}
