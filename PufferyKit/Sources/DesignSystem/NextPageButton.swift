import SwiftUI
import AckeeTracker

public struct NextPageButton: View {
    @Binding var currentPage: Int
    
    public init(_ currentPage: Binding<Int>) {
        self._currentPage = currentPage
    }
    
    public var body: some View {
        Button(action: { currentPage += 1 }, label: {
            Image(systemName: "arrow.right")
                .font(.title)
                .accentColor(.primary)
                .padding()
        })
    }
}
