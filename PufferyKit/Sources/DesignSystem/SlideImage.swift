import SwiftUI

public struct SlideImage: View {
    var image: Image
    
    public init(_ name: String) {
        image = Image(name)
    }
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        image
            .padding()
    }
}
