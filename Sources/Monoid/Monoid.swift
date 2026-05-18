import Foundation

public struct Monoid<Entity> {
    public let identity: Entity
    private let semigroup: Semigroup<Entity>

    public init(identity: Entity, combining: @escaping (Entity, Entity) -> Entity) {
        self.identity = identity
        self.semigroup = .init(combining: combining)
    }

    public init(identity: Entity, semigroup: Semigroup<Entity>) {
        self.identity = identity
        self.semigroup = semigroup
    }

    public func combine(_ lhs: Entity, _ rhs: Entity) -> Entity {
        semigroup.combine(lhs, rhs)
    }

    public func reduce<C: Collection>(_ items: C) -> Entity where C.Element == Entity {
        items.reduce(identity) { partialResult, item in combine(partialResult, item) }
    }
}
