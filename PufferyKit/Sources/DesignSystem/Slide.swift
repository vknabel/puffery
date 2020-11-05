import SwiftUI

public struct Slide<Body: View>: View {
    @Binding var currentPage: Int
    var contents: Body
    
    public init(_ currentPage: Binding<Int>, @ViewBuilder contents: () -> Body) {
        _currentPage = currentPage
        self.contents = contents()
    }
    
    public var body: some View {
        VStack {
            contents
            NextPageButton($currentPage)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}
