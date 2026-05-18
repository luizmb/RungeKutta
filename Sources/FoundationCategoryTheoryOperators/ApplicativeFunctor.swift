import Foundation
import FoundationCategoryTheory
import CompositionOperators

// Optional
public func <*> <A, B>(fa2b: Optional<(A) -> B>, fa: A?) -> B? {
    fa.apply(fa2b)
}

// Array
public func <*> <A, B>(fa2b: Array<(A) -> B>, fa: [A]) -> [B] {
    fa.apply(fa2b)
}

// Result
public func <*> <A, B, E: Error>(fa2b: Result<(A) -> B, E>, fa: Result<A, E>) -> Result<B, E> {
    fa.apply(fa2b)
}

// Publisher
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func <*> <A, B, E: Error>(fa2b: any Publisher<(A) -> B, E>, fa: any Publisher<A, E>) -> any Publisher<B, E> {
    fa.apply(fa2b)
}
#endif
