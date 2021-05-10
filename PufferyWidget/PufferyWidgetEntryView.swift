import Intents
import PufferyKit
import PufferyUI
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
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text(messageDateDescription)
                        .font(.caption)
                        .foregroundColor(message.color.secondary)

                    Text(message.title)
                        .font(.headline)
                }

                Text(message.body)
                    .font(.footnote)
                Spacer(minLength: 0)
            }
            .padding([.top, .leading, .trailing])
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .background(message.color)
            .foregroundColor(message.color.foregroundColor)
            .widgetURL(URL(string: "puffery://puffery.app/open/\(message.id)/\(entry.configuration.channel?.identifier ?? "")"))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("x min ago")
                        .font(.caption)
                        .foregroundColor(Message.Color.gray.foregroundColor)

                    Text("Lorem ipsum")
                        .font(.headline)
                        .foregroundColor(Message.Color.gray.foregroundColor)
                }

                Text("dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt")
                    .font(.subheadline)
                    .foregroundColor(Message.Color.gray.foregroundColor)
                Spacer(minLength: 0)
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
        PufferyWidgetEntryView(entry: MessageEntry(message: Message(
            id: UUID(),
            title: "Upgrading a server-side Swift project to Vapor 3",
            body: "The past few days I created a new server using Vapor and hit which created a Vapor 3 server. ",
            colorName: "blue",
            channel: UUID(),
            createdAt: Date()
        ), configuration: ChannelWidgetsIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
