import Foundation

extension Strideable {
    public func plusMinus(_ number: Stride) -> ClosedRange<Self> {
        (advanced(by: -abs(number)) ... advanced(by: abs(number)))
    }
}
