import Foundation

public typealias Endomorphism<T> = Function<T, T>

extension Endomorphism where Input == Output {
    public typealias T = Input
}
