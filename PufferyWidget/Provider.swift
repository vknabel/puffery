import PufferyKit
import PufferyUI
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

    func getTimeline(for configuration: ChannelWidgetsIntent, in context: Context, completion: @escaping (Timeline<MessageEntry>) -> Void) {
        fetchTimelineEntries(for: configuration, in: context) { entries in
            let timeline: Timeline<MessageEntry>
            if let entries = entries, !entries.isEmpty {
                timeline = Timeline(entries: entries, policy: .never)
            } else {
                timeline = Timeline(entries: [], policy: TimelineReloadPolicy.after(Date(timeIntervalSinceNow: 60)))
            }
            completion(timeline)
        }
    }

    private func fetchTimelineEntries(for configuration: ChannelWidgetsIntent, in _: Context, completion: @escaping ([MessageEntry]?) -> Void) {
        let messages: Endpoint<[Message]>
        guard Current.store.state.session.isLoggedIn() else {
            completion([MessageEntry(message: nil, configuration: configuration)])
            return
        }
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
                    completion([MessageEntry(message: nil, configuration: configuration)])
                }
            }
    }
}
