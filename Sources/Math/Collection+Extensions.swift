import Foundation

extension Array {
    /// Given 2 arrays, return the cartesian product of them.
    /// `cartesian([1, 3, 5], ["a", "b"])` ==> `[(1, "a"), (1, "b"), (3, "a"), (3, "b"), (5, "a"), (5, "b")]`
    /// Cartesian product combines all from the left with all from the right, so it's different from `zip` that
    /// only matches same indexes
    ///
    /// - Parameters:
    ///   - first: Left-hand side of each resulting tuple
    ///   - second: Right-hand side of each resulting tuple
    /// - Returns: Array of tuples combining all elements from the left array with all elements of right array
    public static func cartesian<A1, A2>(_ first: [A1], _ second: [A2]) -> [(A1, A2)] where Element == (A1, A2) {
        first.reduce([(A1, A2)]()) { externalPrevious, firstElement in
            externalPrevious + second.reduce([(A1, A2)]()) { internalPrevious, secondElement in
                internalPrevious + [(firstElement, secondElement)]
            }
        }
    }

    public static func cartesian<A, B, C>(_ first: [A], _ second: [B], _ third: [C]) -> [(A, B, C)] where Element == (A, B, C) {
        Array<((A, B), C)>.cartesian(Array<(A, B)>.cartesian(first, second), third).map { ab, c in (ab.0, ab.1, c) }
    }

    public static func cartesian<A, B, C, D>(_ first: [A], _ second: [B], _ third: [C], _ fourth: [D]) -> [(A, B, C, D)] where Element == (A, B, C, D) {
        Array<((A, B), (C, D))>.cartesian(
            Array<(A, B)>.cartesian(first, second),
            Array<(C, D)>.cartesian(third, fourth)
        ).map { ab, cd in (ab.0, ab.1, cd.0, cd.1) }
    }
}
