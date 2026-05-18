import Foundation
import Monoid

// MARK: - Numbers
extension AdditiveArithmetic {
    public static var sumMonoid: Monoid<Int> {
        Monoid(identity: 0, combining: +)
    }

    public static var productMonoid: Monoid<Int> {
        Monoid(identity: 1, combining: *)
    }

    // Subtraction, Division, Power of and n-Root are semigroup but not monoid.
}

// MARK: - Bool
extension Bool {
    public static var orMonoid: Monoid<Bool> {
        Monoid(identity: false, combining: { $0 || $1 })
    }

    public static var andMonoid: Monoid<Bool> {
        Monoid(identity: true, combining: { $0 && $1 })
    }

    public static var xorMonoid: Monoid<Bool> {
        Monoid(identity: false, combining: { $0 != $1 })
    }

    public static var xnorMonoid: Monoid<Bool> {
        Monoid(identity: true, combining: { $0 == $1 })
    }

    // NAND and NOR are semigroup but not monoid. No neutral element for all combinations.
}

// MARK: - String
extension String: HasDefaultMonoid {
    public static var defaultMonoid: Monoid<String> {
        Monoid(identity: "", combining: +)
    }
}

// MARK: - Array
extension Array: HasDefaultMonoid {
    public static var defaultMonoid: Monoid<Self> {
        Monoid(identity: [], combining: +)
    }
}

// MARK: - Set
extension Set {
    public static var destructiveuUnionMonoid: Monoid<Self> {
        Monoid(identity: [], combining: { lhs, rhs in lhs.union(rhs) })
    }

    public static func mergingUnionMonoid(using monoid: Monoid<Element>) -> Monoid<Self> {
        Monoid(identity: [], combining: { lhs, rhs in
            var rhs = rhs
            return lhs.reduce(into: Set<Element>()) { partialResult, elementLeft in
                if let elementRight = rhs.remove(elementLeft) {
                    partialResult.insert(monoid.combine(elementLeft, elementRight))
                } else {
                    partialResult.insert(elementLeft)
                }
            }.union(rhs)
        })
    }
}

extension Set where Element: HasDefaultMonoid {
    public static func mergingUnionMonoid() -> Monoid<Self> {
        mergingUnionMonoid(using: Element.defaultMonoid)
    }
}

// MARK: - Dictionary
extension Dictionary {
    public static var leftPriorityMonoid: Monoid<Self> {
        Monoid(identity: [:], combining: { lhs, rhs in
            lhs.merging(rhs) { elementLeft, _ in
                elementLeft
            }
        })
    }
    public static var rightPriorityMonoid: Monoid<Self> {
        Monoid(identity: [:], combining: { lhs, rhs in
            lhs.merging(rhs) { _, elementRight in
                elementRight
            }
        })
    }
    public static func asMonoid(using monoid: Monoid<Value>) -> Monoid<Self> {
        Monoid(identity: [:], combining: { lhs, rhs in
            lhs.merging(rhs) { elementLeft, elementRight in
                monoid.combine(elementLeft, elementRight)
            }
        })
    }
}

extension Dictionary: HasDefaultMonoid where Value: HasDefaultMonoid {
    public static var defaultMonoid: Monoid<Self> {
        asMonoid(using: Value.defaultMonoid)
    }
}

// MARK: - Optional
extension Optional: HasDefaultMonoid where Wrapped: HasDefaultMonoid {
    public static var defaultMonoid: Monoid<Wrapped?> {
        asMonoid(using: Wrapped.defaultMonoid)
    }
}

extension Optional {
    public static func asMonoid(using monoid: Monoid<Wrapped>) -> Monoid<Self> {
        Monoid<Wrapped?>(
            identity: nil,
            combining: { lhs, rhs in
                switch (lhs, rhs) {
                case (nil, nil): nil
                case let (lhs?, nil): lhs
                case let (nil, rhs?): rhs
                case let (.some(lhs), .some(rhs)): monoid.combine(lhs, rhs)
                }
            }
        )
    }
}
