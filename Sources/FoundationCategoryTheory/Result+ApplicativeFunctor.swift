import Foundation

extension Result {
    public func apply<B>(_ f: Result<(Success) -> B, Failure>) -> Result<B, Failure> {
        zip(self, f).map { (a, f) in f(a) }
    }
}

/// Creates a result of a pair built out of two wrapped result values if both succeed, or an error result with
/// left-hand-side error or right-hand-side error, what comes first.
///
/// - Parameters:
///   - resultLhs: first result type
///   - resultRhs: second result type
/// - Returns: result of a tuple
public func zip<A, B, E: Error>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
        switch (a, b) {
        case let (.success(lhs), .success(rhs)):
            .success((lhs, rhs))
        case let (.failure(error), _):
            .failure(error)
        case let (_, .failure(error)):
            .failure(error)
        }
}

/// Creates a result of a tuple built out of 3 wrapped result values, or an error result with the error found first
///
/// - Parameters:
///   - resultA: first result type
///   - resultB: second result type
///   - resultC: third result type
/// - Returns: result of a tuple
public func zip<A, B, C, E: Error>(_ a: Result<A, E>, _ b: Result<B, E>, _ c: Result<C, E>) -> Result<(A, B, C), E> {
    return zip(a, zip(b, c)).map { sideA, sideBC in (sideA, sideBC.0, sideBC.1) }
}

/// Creates a result of a tuple built out of 4 wrapped result values, or an error result with the error found first
///
/// - Parameters:
///   - resultA: first result type
///   - resultB: second result type
///   - resultC: third result type
///   - resultD: fourth result type
/// - Returns: result of a tuple
public func zip<A, B, C, D, E: Error>(_ a: Result<A, E>, _ b: Result<B, E>, _ c: Result<C, E>, _ d: Result<D, E>) -> Result<(A, B, C, D), E> {
    return zip(a, zip(b, zip(c, d))).map { sideA, sideBCD in (sideA, sideBCD.0, sideBCD.1.0, sideBCD.1.1) }
}

extension Result {
    /// Zips the current result with a second, that is, it creates a result of a pair built out of two wrapped
    /// result values if both succeed, or an error result with left-hand-side error or right-hand-side error, what comes first.
    ///
    /// - Parameter other: a second result type
    /// - Returns: result of a tuple
    public func fanout<B>(_ other: @autoclosure () -> Result<B, Failure>) -> Result<(Success, B), Failure> {
        return zip(self, other())
    }
}
