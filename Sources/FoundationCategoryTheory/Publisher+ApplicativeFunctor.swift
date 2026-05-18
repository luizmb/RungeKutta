#if canImport(Combine)
import Foundation
import Combine
import Monoid

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func apply<B>(_ f: any Publisher<(Output) -> B, Failure>) -> any Publisher<B, Failure> {
        FoundationCategoryTheory.zip(self, f.eraseToAnyPublisher())
            .map { (a, f) in f(a) }
            .eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func zip<A, B, E: Error>(_ a: any Publisher<A, E>, _ b: any Publisher<B, E>) -> AnyPublisher<(A, B), E> {
    Publishers.Zip(a.eraseToAnyPublisher(), b.eraseToAnyPublisher()).eraseToAnyPublisher()
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func zip<A, B, C, E: Error>(_ a: any Publisher<A, E>, _ b: any Publisher<B, E>, _ c: any Publisher<C, E>) -> any Publisher<(A, B, C), E> {
    return zip(a, zip(b, c)).eraseToAnyPublisher().map { sideA, sideBC in (sideA, sideBC.0, sideBC.1) }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func zip<A, B, C, D, E: Error>(_ a: any Publisher<A, E>, _ b: any Publisher<B, E>, _ c: any Publisher<C, E>, _ d: any Publisher<D, E>) -> any Publisher<(A, B, C, D), E> {
    return zip(a, zip(b, zip(c, d))).eraseToAnyPublisher().map { sideA, sideBCD in (sideA, sideBCD.0, sideBCD.1.0, sideBCD.1.1) }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func fanout<B>(_ other: @autoclosure () -> any Publisher<B, Failure>) -> any Publisher<(Output, B), Failure> {
        return FoundationCategoryTheory.zip(self, other().eraseToAnyPublisher()).eraseToAnyPublisher()
    }
}
#endif
