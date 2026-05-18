import Foundation

extension ℝ {
    public func error(from expected: Self) -> Self {
        abs(expected - self)
    }
}
