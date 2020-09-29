import Intents
import PufferyKit

@available(iOSApplicationExtension 14.0, *)
@objc class ChannelWidgetsIntentHandler: NSObject, ChannelWidgetsIntentHandling {
    private var allChannelsIntent: ChannelWidget {
        ChannelWidget(identifier: nil, display: "All")
    }

    func resolveChannel(for intent: ChannelWidgetsIntent, with completion: @escaping (ChannelWidgetResolutionResult) -> Void) {
        if let intentChannel = intent.channel, let channelId = intentChannel.identifier.flatMap(UUID.init(uuidString:)) {
            Current.api.channel(id: channelId).task { result in
                if case let .success(channel) = result {
                    completion(.success(with: ChannelWidget(identifier: channel.id.uuidString, display: channel.title)))
                } else {
                    completion(.success(with: self.allChannelsIntent))
                }
            }
        } else {
            completion(.success(with: allChannelsIntent))
        }
    }
    
    func provideChannelOptionsCollection(for intent: ChannelWidgetsIntent, with completion: @escaping (INObjectCollection<ChannelWidget>?, Error?) -> Void) {
        Current.api.channels().task { result in
            switch result {
            case let .success(channels):
                let channelIntents = channels.map {
                    ChannelWidget(identifier: $0.id.uuidString, display: $0.title)
                }
                completion(INObjectCollection(items: [self.allChannelsIntent] + channelIntents), nil)
            case let .failure(error):
                completion(INObjectCollection(items: [self.allChannelsIntent]), error)
            }
        }
    }
    
    func defaultChannel(for intent: ChannelWidgetsIntent) -> ChannelWidget? {
        allChannelsIntent
    }
 }
