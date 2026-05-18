import Foundation

extension Array {
    public func apply<B>(_ f: Array<(Element) -> B>) -> [B] {
        zip(self, f).map { (a, f) in f(a) }
    }
}
