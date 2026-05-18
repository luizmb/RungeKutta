import Foundation
import Morphisms

/*
 Monad flatMap operator
 >>=

 Monad flatMap
 - Left: monad of a: M<A>
 - Right: function from a to monad of b a2mb: (A) -> M<B>
 - Return: monad of b: M<B>
 */

// Function
public func >>= <Input, A, B>(ma: Function<Input, A>, transform: @escaping (A) -> Function<Input, B>) -> Function<Input, B> {
    ma.flatMap(transform)
}

public func >>= <Input, A, B>(ma: @escaping (Input) -> A, transform: @escaping (A) -> (Input) -> B) -> Function<Input, B> {
    (^ma).flatMap(transform)
}

public func >>= <Input, A, B>(ma: Function<Input, A>, transform: @escaping (A) -> (Input) -> B) -> Function<Input, B> {
    ma.flatMap(transform)
}

public func >>= <Input, A, B>(ma: @escaping (Input) -> A, transform: @escaping (A) -> Function<Input, B>) -> Function<Input, B> {
    (^ma).flatMap(transform)
}

/*
 Klesli arrows operator (Monad fishbone operator)
 >=>

 Monad composition
 - Left: a to monad of b a2mb: (A) -> M<B>
 - Right: b to monad of c b2mc: (B) -> M<C>
 - Return: a to monad of c a2mc: (A) -> M<C>

 * left associativity
 * precedence group: Klesli
 */
infix operator >=>: Klesli
precedencegroup Klesli {
    associativity: left
    higherThan: Apply
}

// Monad m => (a -> m b) -> (b -> m c) -> a -> m c
// Function
public func >=> <Input, A, B, C>(a2mb: @escaping (A) -> Function<Input, B>, b2mc: @escaping (B) -> Function<Input, C>) -> (A) -> Function<Input, C> {
    { a in
        a2mb(a).flatMap(b2mc)
    }
}
