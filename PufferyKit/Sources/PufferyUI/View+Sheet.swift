import SwiftUI

private struct IdentifiableString: Identifiable {
    let id: String
}

extension View {
    func sheet<Content>(string: Binding<String?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (String) -> Content) -> some View where Content : View {
        let mappedBinding = Binding<IdentifiableString?>(
            get: { string.wrappedValue.map(IdentifiableString.init(id:)) },
            set: { string.wrappedValue = $0?.id }
        )
        return sheet(
            item: mappedBinding,
            onDismiss: onDismiss,
            content: { content($0.id) }
        )
    }
}
