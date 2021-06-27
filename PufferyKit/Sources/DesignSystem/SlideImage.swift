import SwiftUI
import UIKit

public struct SlideImage: View {
    var image: Image
    var maxSize: CGSize
    
    public init(_ name: String) {
        self.init(uiImage: UIImage(named: name)!)
    }
    
    public init(uiImage: UIImage) {
        image = Image(uiImage: uiImage)
        maxSize = uiImage.size
    }
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: maxSize.width, maxHeight: maxSize.height)
            .padding()
    }
}
