import SwiftUI

public extension View {
    func show(when predicate: Bool) -> some View {
        Group {
            if predicate {
                self
            }
        }
    }
}
