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
        fetchTimelineEntries(for: configuration, in: context) { entry in
            let timeline: Timeline<MessageEntry>
            if let entry = entry {
                timeline = Timeline(entries: [entry], policy: .never)
            } else {
                timeline = Timeline(entries: [], policy: TimelineReloadPolicy.after(Date(timeIntervalSinceNow: 60)))
            }
            completion(timeline)
        }
    }

    private func fetchTimelineEntries(for configuration: ChannelWidgetsIntent, in _: Context, completion: @escaping (MessageEntry?) -> Void) {
        let messages: Endpoint<[Message]>
        guard Current.store.state.session.isLoggedIn() else {
            completion(MessageEntry(message: nil, configuration: configuration))
            return
        }
        if let channelId = configuration.channel?.identifier.flatMap(UUID.init(uuidString:)) {
            messages = Current.api.messages(ofChannel: Channel(id: channelId, title: "", receiveOnlyKey: "", notifyKey: nil, isSilent: true), pagination: PaginationRequest(page: 1, limit: 1))
        } else {
            messages = Current.api.messages(pagination: PaginationRequest(page: 1, limit: 1))
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
                    completion(entries.first)
                case let .failure(error):
                    print(error)
                    completion(MessageEntry(message: nil, configuration: configuration))
                }
            }
    }
}
