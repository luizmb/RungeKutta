import Foundation
import Morphisms
import RealNumber

public typealias Fn<NumericType> = Endomorphism<NumericType> where NumericType: ℝ

extension Fn where Input == Output, T: ℝ {
    public typealias NumericType = T
}
