import Foundation
import Morphisms

prefix operator ^
public prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> Function<Root, Value> {
    ^{ root in
        root[keyPath: keyPath]
    }
}

public prefix func ^ <Root, Value1, Value2>(keyPaths: (KeyPath<Root, Value1>, KeyPath<Root, Value2>)) -> Function<Root, (Value1, Value2)> {
    ^{ root in
        (root[keyPath: keyPaths.0], root[keyPath: keyPaths.1])
    }
}

public prefix func ^ <Root, Value1, Value2, Value3>(
        keyPaths: (KeyPath<Root, Value1>, KeyPath<Root, Value2>, KeyPath<Root, Value3>)
    ) -> Function<Root, (Value1, Value2, Value3)> {
    ^{ root in
        (root[keyPath: keyPaths.0], root[keyPath: keyPaths.1], root[keyPath: keyPaths.2])
    }
}

public prefix func ^ <Root, Value1, Value2, Value3, Value4>(
        keyPaths: (KeyPath<Root, Value1>, KeyPath<Root, Value2>, KeyPath<Root, Value3>, KeyPath<Root, Value4>)
    ) -> Function<Root, (Value1, Value2, Value3, Value4)> {
    ^{ root in
        (root[keyPath: keyPaths.0], root[keyPath: keyPaths.1], root[keyPath: keyPaths.2], root[keyPath: keyPaths.3])
    }
}

public prefix func ^ <Input, Output>(fn: @escaping (Input) -> Output) -> Function<Input, Output> {
    Function(fn)
}

public prefix func ^ <I1, I2, Output>(fn: @escaping (I1, I2) -> Output) -> Function2<I1, I2, Output> {
    Function2(fn)
}

public prefix func ^ <I1, I2, I3, Output>(fn: @escaping (I1, I2, I3) -> Output) -> Function3<I1, I2, I3, Output> {
    Function3(fn)
}

public prefix func ^ <I1, I2, I3, I4, Output>(fn: @escaping (I1, I2, I3, I4) -> Output) -> Function4<I1, I2, I3, I4, Output> {
    Function4(fn)
}

public prefix func ^ <I1, I2, I3, I4, I5, Output>(fn: @escaping (I1, I2, I3, I4, I5) -> Output) -> Function5<I1, I2, I3, I4, I5, Output> {
    Function5(fn)
}

public prefix func ^ <I1, I2, I3, I4, I5, I6, Output>(fn: @escaping (I1, I2, I3, I4, I5, I6) -> Output) -> Function6<I1, I2, I3, I4, I5, I6, Output> {
    Function6(fn)
}

public prefix func ^ <I1, I2, I3, I4, I5, I6, I7, Output>(fn: @escaping (I1, I2, I3, I4, I5, I6, I7) -> Output) -> Function7<I1, I2, I3, I4, I5, I6, I7, Output> {
    Function7(fn)
}
