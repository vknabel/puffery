import SwiftUI
import PlatformSupport

public struct Slide<Body: View>: View {
    @ObservedObject private var keyboard = Keyboard.shared

    @Binding var currentPage: Int
    var image: SlideImage
    var contents: Body
    var showsPageControls: Bool
    
    public init(
        _ currentPage: Binding<Int>,
        imageNamed: String,
        showsPageControls: Bool = true,
        @ViewBuilder contents: () -> Body
    ) {
        _currentPage = currentPage
        image = SlideImage(imageNamed)
        self.showsPageControls = showsPageControls
        self.contents = contents()
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            if !keyboard.isActive {
                image.transition(.opacity)
            }
            contents
            
            if showsPageControls && !keyboard.isActive {
                NextPageButton($currentPage).transition(.opacity)
            }
        }
        .padding()
        .padding(.bottom, 30)
        .navigationBarTitle("")
        .frame(maxWidth: 350)
    }
}
