//
//  ChannelDetailsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Overture
import SwiftUI

struct ChannelDetailsPage: View {
    var channel: Channel?

    private var api: API { Current.api }
    private var tokens: TokenRepository { Current.tokens }
    @State var displaysChannelSettings = false

    var loadMessagesPublisher: AnyPublisher<[Message], FetchingError> {
        channel.map(api.messages(ofChannel:))?.publisher()
            ?? api.messages().publisher()
    }

    var body: some View {
        Fetching(loadMessagesPublisher, empty: self.noMessages) { messages in
            MessageList(messages: messages)
        }
        .navigationBarTitle(self.channel?.title ?? "All")
        .navigationBarItems(trailing:
            channel.map { channel in
                Button(action: { self.displaysChannelSettings.toggle() }) {
                    Image(systemName: "wrench")
                        .padding()
                        .sheet(isPresented: self.$displaysChannelSettings) {
                            NavigationView {
                                ChannelSettingsPage(channel: channel)
                            }.navigationViewStyle(StackNavigationViewStyle())
                        }
                }
            }
        )
        .onAppear { Current.tracker.record("channels/:id") }
    }

    var noMessages: some View {
        VStack(spacing: 8) {
            Text("No messages, yet.")
            noMessageHelperText().map(Text.init(_:))

            noMessageCodeExampleText().map { codeExample in
                Text(codeExample).padding().onTapGesture {
                    UIPasteboard.general.string = codeExample
                }
                .font(.system(Font.TextStyle.footnote, design: .monospaced))
            }
        }
    }

    func noMessageHelperText() -> String? {
        if channel?.notifyKey != nil {
            return "Create your own messages!"
        } else if channel != nil {
            return "Stay tuned for the author!"
        } else {
            return "Create new channels or messages!"
        }
    }

    func noMessageCodeExampleText() -> String? {
        if let channel = channel, let privateToken = channel.notifyKey {
            return """
            curl "\(Current.config.apiURL.absoluteString)/notify/\(privateToken)" \\
            --form-string "title=Hello from \(channel.title)" \\
            --form-string "body=Some details" \\
            --form-string "color=green"
            """
        } else {
            return nil
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
