import Foundation
import Monoid

/*
 Semigroup composition precedence group
 - left associativity
 - BitwiseShiftPrecedence > SemigroupJoin > MultiplicationPrecedence
 */
precedencegroup SemigroupJoin {
    associativity: left
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
}

/*
 Semigroup composition operator (aka Diamond operator, single type compose operator)
 <>

 1) Combines two element of same type into one. Sums, multiplications and boolean logic binary operations are all
 semigroup composition, as they transform (A, A) -> A, for any A that implements semi-groups protocol.

 2) Compose two functions with same signature from A to A, and merges them into a new function from A to A, or in
 other words it's a forward composition where A, B and C are of the same type
 - Left: function A to A
 - Right: function A to A
 - Return: function A to A

 3) Compose two functions with same signature from in/out A to Void, and merges them into a new function from
 in/out A to Void, or in other words it's the same as previous operation but with in/out A to Void instead of
 A to A
 - Left: function inout A to Void
 - Right: function inout A to Void
 - Return: function inout A to Void

 Behaviour:
 - left associativity
 - precedence group: SemigroupJoin
 - BitwiseShiftPrecedence > SemigroupJoin > MultiplicationPrecedence
 */
infix operator <>: SemigroupJoin

extension HasDefaultMonoid {
    public static func <> (lhs: Self, rhs: Self) -> Self {
        Self.defaultMonoid.combine(lhs, rhs)
    }
}
