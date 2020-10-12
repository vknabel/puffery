import PufferyKit
import PufferyUI
import Intents
import SwiftUI
import WidgetKit

struct PufferyWidgetEntryView: View {
    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var entry: Provider.Entry
    var message: Message? {
        return entry.message
    }

    var body: some View {
        if let message = message {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(message.title)
                        .font(.headline)

                    Spacer()

                    Text(messageDateDescription)
                        .font(.caption)
                        .foregroundColor(message.color.secondary)
                }

                Text(message.body)
                    .font(.subheadline)
                Spacer()
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .background(message.color)
            .foregroundColor(message.color.foregroundColor)
        } else {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Lorem ipsum")
                        .font(.headline)
                        .foregroundColor(Message.Color.gray.foregroundColor)
                    Spacer()
                    
                    Text("Lorem")
                        .font(.caption)
                        .foregroundColor(Message.Color.gray.foregroundColor)
                }
                    
                Text("dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt")
                    .font(.subheadline)
                    .foregroundColor(Message.Color.gray.foregroundColor)
                Spacer()
            }
            .padding()
            .background(Message.Color.gray)
            .redacted(reason: .placeholder)
        }
    }

    var messageDateDescription: String {
        guard let message = message else {
            return "Lorem"
        }
        return PufferyWidgetEntryView.dateFormatter.localizedString(for: message.createdAt, relativeTo: Date())
    }
}

struct PufferyWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PufferyWidgetEntryView(entry: MessageEntry(message: Message(id: UUID(), title: "Upgrading a server-side Swift project to Vapor 3", body: "The past few days I created a new server using Vapor and hit which created a Vapor 3 server. ", colorName: "blue", channel: UUID(), createdAt: Date()), configuration: ChannelWidgetsIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
