import Foundation
import Morphisms

/*
 Apply operator (Applicative Functors)
 <*>

 Apply function
 - Left: applicative functor fa2b: F<A -> B>
 - Right: functor fa: F<A>
 - Return: functor fb: F<B>

 * left associativity
 * precedence group: Apply
 */
infix operator <*>: Apply
precedencegroup Apply {
    associativity: left
    higherThan: AssignmentPrecedence
}

// Function
public func <*> <A, B, C>(fb2c: Function<A, (B) -> C>, fb: Function<A, B>) -> Function<A, C> {
    fb.apply(fb2c)
}

public func <*> <A, B, C>(fb2c: @escaping ((A) -> (B) -> C), fb: @escaping (A) -> B) -> Function<A, C> {
    (^fb).apply(^fb2c)
}

public func <*> <A, B, C>(fb2c: Function<A, (B) -> C>, fb: @escaping (A) -> B) -> Function<A, C> {
    (^fb).apply(fb2c)
}

public func <*> <A, B, C>(fb2c: @escaping ((A) -> (B) -> C), fb: Function<A, B>) -> Function<A, C> {
    fb.apply(^fb2c)
}
