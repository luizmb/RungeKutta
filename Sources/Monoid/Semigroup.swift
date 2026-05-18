import Foundation

public struct Semigroup<Entity> {
    private let combining: (Entity, Entity) -> Entity

    public init(combining: @escaping (Entity, Entity) -> Entity) {
        self.combining = combining
    }

    public func combine(_ lhs: Entity, _ rhs: Entity) -> Entity {
        combining(lhs, rhs)
    }
}
