import Foundation
import Morphisms

/*
 Forward composition operator / Right arrow operator
 >>>

 Compose two functions when output of the left matches input type of the right
 - Left: function A to B
 - Right: function B to C
 - Return: function A to C

 * left associativity
 * precedence group: MorphismComposition
 * MorphismComposition > Forward Application
 */
infix operator >>>: MorphismComposition
precedencegroup MorphismComposition {
    associativity: left
    higherThan: ForwardApplication
}

public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    { a in
        g(f(a))
    }
}

public func >>> <A, B, C>(f: Function<A, B>, g: Function<B, C>) -> Function<A, C> {
    ^{ a in
        g(f(a))
    }
}

public func >>> <A, B, C>(f: @escaping (A) -> B, g: Function<B, C>) -> Function<A, C> {
    ^{ a in
        g(f(a))
    }
}

public func >>> <A, B, C>(f: Function<A, B>, g: @escaping (B) -> C) -> Function<A, C> {
    ^{ a in
        g(f(a))
    }
}

/*
 Backwards composition operator / Left arrow operator
 <<<

 Compose two functions when output of the right matches input type of the left
 - Left: function B to C
 - Right: function A to B
 - Return: function A to C

 * right associativity
 * precedence group: MorphismComposition
 * MorphismComposition > Forward Application
 */
infix operator <<<: MorphismComposition
infix operator •: MorphismComposition

public func <<< <A, B, C>(f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
    { a in
        f(g(a))
    }
}

public func <<< <A, B, C>(f: Function<B, C>, g: Function<A, B>) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}

public func <<< <A, B, C>(f: @escaping (B) -> C, g: Function<A, B>) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}

public func <<< <A, B, C>(f: Function<B, C>, g: @escaping (A) -> B) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}

public func • <A, B, C>(f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
    { a in
        f(g(a))
    }
}

public func • <A, B, C>(f: Function<B, C>, g: Function<A, B>) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}

public func • <A, B, C>(f: @escaping (B) -> C, g: Function<A, B>) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}

public func • <A, B, C>(f: Function<B, C>, g: @escaping (A) -> B) -> Function<A, C> {
    ^{ a in
        f(g(a))
    }
}
