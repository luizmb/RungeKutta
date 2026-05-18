import Foundation

precedencegroup ApproximateEquality {
    associativity: left
    lowerThan: ComparisonPrecedence
    higherThan: LogicalConjunctionPrecedence
}

infix operator ≅: ApproximateEquality

/// Approximately equals to another number, that is given by a range. This is a short-form of asking if the base number
/// is within some range: `base.within(range)`. It can be used together with the operator ± to create a mathematical
/// expression in order to evaluate equality of a number against other, relaxing the comparison by providing an accuracy.
/// For example:
/// `42 ≅ 41 ± 1` is expected to return true, as we want to know if 42 is within the range from 40 to 42
/// `42 ≅ 30 ± 15` is expected to return true, as we want to know if 42 is within the range from 15 to 45
/// `42 ≅ 42 ± 0` is expected to return true, as we want to know if 42 is within the range from 42 to 42
/// `42 ≅ 41.5 ± 0.5` is expected to return true, as we want to know if 42 is within the range from 41 to 42
/// `42 ≅ 40 ± 1` is expected to return *false*, as we want to know if 42 is within the range from 39 to 41 and we know
/// that 42 is greater than the higher-bound, therefore the range doesn't contain the base element.
/// For using ± to create a range, the value must be `Strideable` as well.
///
/// - Parameter base: the number on the left-hand-side of this expression is the base number we are evaluating against
///                   certain range.
/// - Parameter range: The range to compare the base element with. The return will be true if the base is greater or
///                    equals to the lower-bound of this range, and also lower or equals to the higher-bound of this
///                    range.
public func ≅ <T: Comparable>(_ base: T, _ range: ClosedRange<T>) -> Bool {
    base.within(range)
}

public func ~= <T: Comparable>(_ base: T, _ range: ClosedRange<T>) -> Bool {
    base.within(range)
}
