import SwiftUI

#if os(macOS)
    extension View {
        func navigationBarTitle(_: LocalizedStringKey) -> some View {
            self
        }
    }

    typealias StackNavigationViewStyle = DoubleColumnNavigationViewStyle

    typealias UIFont = NSFont
#endif

func sizeChangePublisher() -> NotificationCenter.Publisher {
    #if canImport(UIKit)
        return NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    #elseif canImport(AppKit)
        return NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)
    #endif
}
