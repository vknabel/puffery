//
//  PufferyWidget.swift
//  PufferyWidget
//
//  Created by Valentin Knabel on 29.09.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    func placeholder(in _: Context) -> MessageEntry {
        MessageEntry(message: nil, configuration: ChannelWidgetsIntent())
    }

    func getSnapshot(for configuration: ChannelWidgetsIntent, in _: Context, completion: @escaping (MessageEntry) -> Void) {
        let entry = MessageEntry(message: nil, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ChannelWidgetsIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        fetchTimelineEntries(for: configuration, in: context) { entries in
            let timeline: Timeline<MessageEntry>
            if let entries = entries {
                timeline = Timeline(entries: entries, policy: .atEnd)
            } else {
                timeline = Timeline(entries: [], policy: TimelineReloadPolicy.after(Date(timeIntervalSinceNow: 60)))
            }
            completion(timeline)
        }
    }

    private func fetchTimelineEntries(for configuration: ChannelWidgetsIntent, in _: Context, completion: @escaping ([MessageEntry]?) -> Void) {
        let messages: Endpoint<[Message]>

        if let channelId = configuration.channel?.identifier.flatMap(UUID.init(uuidString:)) {
            messages = Current.api.messages(ofChannel: Channel(id: channelId, title: "", receiveOnlyKey: "", notifyKey: nil, isSilent: true))
        } else {
            messages = Current.api.messages()
        }
        messages
            .map {
                $0.map { message in
                    MessageEntry(message: message, configuration: configuration)
                }
            }
            .task { result in
                switch result {
                case let .success(entries):
                    completion(entries)
                case let .failure(error):
                    print(error)
                    completion(nil)
                }
            }
    }
}

import PufferyKit
import PufferyUI

struct MessageEntry: TimelineEntry {
    let message: Message?
    let configuration: ChannelWidgetsIntent

    var date: Date {
        message?.createdAt ?? Date.distantPast
    }
}

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
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
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
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .background(message.color)
            .foregroundColor(message.color.foregroundColor)
        } else {
            VStack(alignment: .leading) {
                Spacer()
                Text("Lorem ipsum")
                    .font(.headline)
                    .foregroundColor(Message.Color.gray.foregroundColor)
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

@main
struct PufferyWidget: Widget {
    let kind: String = "PufferyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ChannelWidgetsIntent.self, provider: Provider()) { entry in
            PufferyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("News")
        .description("Display latest news.")
    }
}

struct PufferyWidget_Previews: PreviewProvider {
    static var previews: some View {
        PufferyWidgetEntryView(entry: MessageEntry(message: Message(id: UUID(), title: "Upgrading a server-side Swift project to Vapor 3", body: "The past few days I created a new server using Vapor and hit which created a Vapor 3 server. ", colorName: "blue", channel: UUID(), createdAt: Date()), configuration: ChannelWidgetsIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
