import Foundation

extension Collection where Element: HasDefaultMonoid {
    public func reduce() -> Element {
        Element.reduce(self)
    }
}

extension Collection {
    public func reduce(using monoid: Monoid<Element>) -> Element {
        monoid.reduce(self)
    }
}
