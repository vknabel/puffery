import Foundation
#if canImport(WidgetKit)
    import WidgetKit
#endif

public enum Widgets {
    public static func reloadAll() {
        if #available(iOS 14.0, *) {
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }

}
