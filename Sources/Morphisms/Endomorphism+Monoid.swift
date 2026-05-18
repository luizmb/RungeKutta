import Foundation
import Monoid

extension Endomorphism: HasDefaultMonoid where Input == Output {
    public static var defaultMonoid: Monoid<Function<Input, Output>> {
        Monoid(
            identity: Self { $0 },
            combining: { lhs, rhs in
                Self { x in
                    rhs(lhs(x))
                }
            }
        )
    }
}
