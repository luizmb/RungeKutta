import Foundation
import FoundationCategoryTheory
import CompositionOperators

// Optional
public func >>= <A, B>(ma: Optional<A>, transform: (A) -> Optional<B>) -> B? {
    ma.flatMap(transform)
}

// Array
public func >>= <A, B>(ma: Array<A>, transform: (A) -> Array<B>) -> [B] {
    ma.flatMap(transform)
}

// Result
public func >>= <A, B, E: Error>(ma: Result<A, E>, transform: (A) -> Result<B, E>) -> Result<B, E> {
    ma.flatMap(transform)
}

// Publisher
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func >>= <A, PublisherB: Publisher, E: Error>(
    ma: any Publisher<A, E>,
    transform: @escaping (A) -> PublisherB
) -> any Publisher<PublisherB.Output, E> where PublisherB.Failure == E {
    ma.eraseToAnyPublisher().flatMap(transform)
}
#endif

// Optional
public func >=> <A, B, C>(a2mb: @escaping (A) -> Optional<B>, b2mc: @escaping (B) -> Optional<C>) -> (A) -> Optional<C> {
    { a in
        a2mb(a).flatMap(b2mc)
    }
}

// Array
public func >=> <A, B, C>(a2mb: @escaping (A) -> Array<B>, b2mc: @escaping (B) -> Array<C>) -> (A) -> Array<C> {
    { a in
        a2mb(a).flatMap(b2mc)
    }
}

// Result
public func >=> <A, B, C, E: Error>(a2mb: @escaping (A) -> Result<B, E>, b2mc: @escaping (B) -> Result<C, E>) -> (A) -> Result<C, E> {
    { a in
        a2mb(a).flatMap(b2mc)
    }
}

// Publisher
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func >=> <A, PublisherB: Publisher, PublisherC: Publisher, E: Error>(
    a2mb: @escaping (A) -> PublisherB,
    b2mc: @escaping (PublisherB.Output) -> PublisherC
) -> (A) -> any Publisher<PublisherC.Output, E> where PublisherB.Failure == E, PublisherC.Failure == E {
    { a in
        a2mb(a).eraseToAnyPublisher().flatMap(b2mc)
    }
}
#endif
