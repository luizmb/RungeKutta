import Foundation

public func scope(_ text: String, _ code: @escaping () -> Void) -> () -> Void {
    return {
        print("****** Example code: \(text) ******")
        code()
    }
}
