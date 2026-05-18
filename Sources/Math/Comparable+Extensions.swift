import Foundation

extension Comparable {

    /// For this element, checks if it's within a certain range of elements, that means, if it's greater or equals to the
    /// lower-bound of the range, and also lower or equals to the higher-bound of the range.
    /// For example, `42.within(40...50)` is true, also is `42.within(40...42)`, however `42.within(30...41)` will be
    /// false, once the number is too high. Another way of doing this is by creating a range from the average number and
    /// a tolerance, for example `42 ± 10` creates a range from 32 to 52: `(32...52)`. That way you can ask things like
    /// `42.within(40 ± 2)` and this will be true because the valid range goes from 38 to 42, inclusive.
    /// For using ± to create a range, the value must be `Strideable` as well.
    ///
    /// - Parameter range: The range to compare the base element with. The return will be true if the base is greater or
    ///                    equals to the lower-bound of this range, and also lower or equals to the higher-bound of this
    ///                    range.
    /// - Returns: true if the base number is in the bounds of the range, false otherwise
    public func within(_ range: ClosedRange<Self>) -> Bool {
        range.contains(self)
    }
}

extension Comparable {
    /// Constrain current comparable value to a certain range. If comparable value is lower than the range, the result
    /// will be the minimum (lower bound), if it is greater than range, the result will be the maximum (upper bound).
    /// If the value is within the range, the result will be itself.
    ///
    /// - Parameter range: Closed range, for example `(0.0 ... 100.0)`
    /// - Returns: A number within the range, that can be the original number itself or minimum/maximum in case the
    ///            original number was lower or higher than expected.
    public func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
