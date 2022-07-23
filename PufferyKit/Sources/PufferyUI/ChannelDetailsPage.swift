//
//  ChannelDetailsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI
import DesignSystem

struct ChannelDetailsPage: View {
    var channel: Channel?

    private var api: API { Current.api }
    @State var displaysChannelSettings = false
    @State var displaysSendMessage = false
    @State var forceReload = PassthroughSubject<Void, FetchingError>()
    @State var shouldLoadNextPage = PassthroughSubject<Void, Never>()

    var loadMessagesPublisher: AnyPublisher<[Message], FetchingError> {
        let fetcher = { pagination in
            channel.map({ api.messages(ofChannel: $0, pagination: pagination) })
            ?? api.messages(pagination: pagination)
        }
        return shouldLoadNextPage.prepend(())
            .scan(0) { page, _ in page + 1 }
            .map { page in
                PaginationRequest(page: page, limit: 20)
            }
            .flatMap { request in
                fetcher(request).publisher()
                    .map({ (page: request.page ?? 1, messages: $0) })
            }
            .prefix(while: { result in
                result.messages.count != 0
            })
            .scan([Int: [Message]]()) { baseCache, fetched in
                var cache = baseCache
                cache[fetched.page] = fetched.messages
                return cache
            }
            .map({ (cache: [Int: [Message]]) -> [Message] in
                cache.sorted(by: { $0.key < $1.key })
                    .flatMap(\.value)
            })
            .eraseToAnyPublisher()
    }
    
    

    var body: some View {
        Fetching(loadMessagesPublisher, forceReload: forceReload, empty: self.noMessages) { messages in
            VStack {
                MessageList(messages: messages, loadNextPage: { shouldLoadNextPage.send(()) })
            }
        }
        .navigationBarTitle(self.channel?.title ?? NSLocalizedString("ChannelDetails.All", comment: "All"))
        .navigationBarItems(trailing:
            channel.map { channel in
                HStack {
                    if #available(iOS 14.0, *) {
                        Button(action: { self.displaysSendMessage.toggle() }, label: {
                            Image(systemName: "paperplane")
                        })
                    }
                    Button(action: { self.displaysChannelSettings.toggle() }) {
                        Image(systemName: "wrench")
                    }
                }
            }
        )
        .sheet(isPresented: self.$displaysChannelSettings) {
            NavigationView {
                if let channel = channel {
                    ChannelSettingsPage(channel: channel)
                } else {
                    EmptyView()
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: self.$displaysSendMessage) {
            NavigationView {
                if let channel = channel, #available(iOS 14.0, *) {
                    MessageCreationPage(channel: channel)
                        .onDisappear(perform: {
                            forceReload.send(())
                        })
                } else {
                    EmptyView()
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        .record(channel != nil ? "channels/:id" : "channels/all")
    }

    var noMessages: some View {
        VStack(spacing: 8) {
            Text("ChannelDetails.NoMessages.Title")
            noMessageHelperText().map { Text($0) }

            channel?.notifyKey.map { notifyKey in
                Text("ChannelSettings.HowTo.CURL.Teaser url:\(Current.config.apiURL.absoluteString)").padding().onTapGesture {
                    UIPasteboard.general.string = String(format: NSLocalizedString("ChannelSettings.HowTo.CURL.Contents url:%@ notify:%@ title:%@", comment: ""), Current.config.apiURL.absoluteString, notifyKey, self.channel!.title)
                }.font(.system(Font.TextStyle.footnote, design: .monospaced))
            }
        }
    }

    func noMessageHelperText() -> LocalizedStringKey? {
        if channel?.notifyKey != nil {
            return "ChannelDetails.NoMessages.HelperNotify"
        } else if channel != nil {
            return "ChannelDetails.NoMessages.HelperReceive"
        } else {
            return "ChannelDetails.NoMessages.HelperAll"
        }
    }
}

#if DEBUG
    struct ChannelDetailsPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelDetailsPage(channel: .puffery)
            }
        }
    }
#endif
