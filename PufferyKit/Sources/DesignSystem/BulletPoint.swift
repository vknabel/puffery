import SwiftUI

public struct InlineBulletPoint: View {
    var icon: Image
    var title: Text
    
    public init(systemName iconName: String, title: LocalizedStringKey) {
        self.init(icon: Image(systemName: iconName), title: Text(title))
    }
    
    public init(icon: Image, title: Text) {
        self.icon = icon
        self.title = title
    }
    
    public var body: some View {
        HStack {
            icon
                .font(.title)
                .foregroundColor(.accentColor)
            title
            Spacer()
        }
    }
}

public struct MultilineBulletPoint: View {
    var icon: Image
    var title: Text
    
    public init(systemName iconName: String, title: LocalizedStringKey) {
        self.init(icon: Image(systemName: iconName), title: Text(title))
    }
    
    public init(icon: Image, title: Text) {
        self.icon = icon
        self.title = title
    }
    
    public var body: some View {
        icon
            .font(.title)
            .foregroundColor(.accentColor)
            .padding()
        title.padding(.horizontal)
    }
}
