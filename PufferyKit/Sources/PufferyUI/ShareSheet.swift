import SwiftUI

#if canImport(UIKit)
    import UIKit

    struct ShareSheet: UIViewControllerRepresentable {
        typealias Callback = UIActivityViewController.CompletionWithItemsHandler

        let activityItems: [Any]
        let applicationActivities: [UIActivity]?
        let completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?

        func makeUIViewController(context _: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities
            )
            controller.completionWithItemsHandler = completionWithItemsHandler
            return controller
        }

        func updateUIViewController(_: UIActivityViewController, context _: Context) {}
    }

#elseif canImport(AppKit)
#endif
