//
//  ChannelDetailsView.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ChannelDetailsView: View {
    var channel: Channel?

    @EnvironmentObject var api: API
    @State var messages: [Message]?
    @State var displaysChannelSettings = false

    var body: some View {
        ZStack {
            messages.map(MessageList.init(messages:))
            ActivityIndicator(isAnimating: messages == nil)
                .onAppear(perform: self.loadMessages)
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
                            }
                        }
                }
            }
        )
        .onAppear(perform: loadMessages)
    }

    private func loadMessages() {
        if let channel = channel {
            api.messages(ofChannel: channel).task(didReceiveMessages(result:))
        } else {
            api.messages(ofDevice: latestDeviceToken).task(didReceiveMessages(result:))
        }
    }

    private func didReceiveMessages(result: Result<[Message], FetchingError>) {
        switch result {
        case let .success(messages):
            self.messages = messages
        case .failure:
            break
        }
    }
}

#if DEBUG
    struct ChannelDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelDetailsView(channel: .puffery, messages: [.dockerImage, .testflight])
            }
        }
    }
#endif
