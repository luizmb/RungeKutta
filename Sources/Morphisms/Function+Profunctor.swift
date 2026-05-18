import Foundation

extension Function {
    public func dimap<NewInput, NewOutput>(
        input: @escaping (NewInput) -> Input,
        output: @escaping (Output) -> NewOutput
    ) -> Function<NewInput, NewOutput> {
        Function<NewInput, NewOutput> { newInput in
            output(self(input(newInput)))
        }
    }
}
