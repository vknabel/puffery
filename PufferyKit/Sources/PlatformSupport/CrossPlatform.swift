import SwiftUI

#if os(macOS)
    extension View {
        public func navigationBarTitle(_: LocalizedStringKey) -> some View {
            self
        }
    }

    public typealias StackNavigationViewStyle = DoubleColumnNavigationViewStyle

    public typealias UIFont = NSFont
#endif

public func sizeChangePublisher() -> NotificationCenter.Publisher {
    #if canImport(UIKit)
        return NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    #elseif canImport(AppKit)
        return NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)
    #endif
}
