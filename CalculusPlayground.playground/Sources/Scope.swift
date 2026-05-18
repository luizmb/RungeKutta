import Foundation

public func scope(_ text: String, _ code: @escaping () -> Void) -> () -> Void {
    {
        print("****** Example code: \(text) ******")
        code()
    }
}
