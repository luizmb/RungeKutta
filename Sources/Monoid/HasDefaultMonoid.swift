import Foundation

public protocol HasDefaultMonoid {
    static var defaultMonoid: Monoid<Self> { get }
}

extension HasDefaultMonoid {
    static var identity: Self {
        defaultMonoid.identity
    }
    static func combine(_ lhs: Self, _ rhs: Self) -> Self {
        defaultMonoid.combine(lhs, rhs)
    }
    public static func reduce<C: Collection>(_ items: C) -> Self where C.Element == Self {
        items.reduce(.identity) { partialResult, item in
            defaultMonoid.combine(partialResult, item)
        }
    }
}
