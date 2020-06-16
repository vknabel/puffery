import UIKit
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = UIActivityViewController.CompletionWithItemsHandler
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.completionWithItemsHandler = completionWithItemsHandler
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
