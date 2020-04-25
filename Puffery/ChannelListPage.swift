//
//  ChannelListPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI

struct ChannelListPage: View {
    @EnvironmentObject var api: API
    @EnvironmentObject var tokens: TokenRepository
    @State var channels: [Channel]?

    @State var presentsSettings = false
    @State var presentsChannelCreation = false

    @State var refreshSubscription: AnyCancellable? = nil

    var body: some View {
        ZStack {
            channels.map { channels in
                List {
                    Section {
                        NavigationLink(destination: ChannelDetailsPage()) {
                            Text("All")
                        }
                    }
                    Section(header: channelsHeader) {
                        ForEach(channels) { channel in
                            NavigationLink(destination: ChannelDetailsPage(channel: channel)) {
                                Text(channel.title)
                            }
                        }
                    }
                }
                .roundedListStyle()
            }

            if channels == nil {
                ActivityIndicator(isAnimating: true)
            }
        }
        .navigationBarTitle("Inbox")
        .navigationBarItems(trailing: settingsNavigationBarItem)
        .onAppear(perform: loadChannels)
        .onAppear { Current.tracker.record("channels") }
    }

    var channelsHeader: some View {
        HStack {
            Text("Channels")
            Spacer()

            Button(action: { self.presentsChannelCreation.toggle() }) {
                Image(systemName: "plus.circle").font(.body)
            }.sheet(isPresented: $presentsChannelCreation, onDismiss: loadChannels) {
                NavigationView {
                    ChannelCreationPage().environmentObject(self.api)
                }
            }
        }
    }

    var settingsNavigationBarItem: some View {
        Button(action: { self.presentsSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .padding()
        }.sheet(isPresented: $presentsSettings) {
            NavigationView {
                AppSettingsPage()
                    .environmentObject(self.api)
            }
        }
    }

    func loadChannels() {
        refreshSubscription = Publishers.Zip(
            api.privateChannels().publisher(),
            api.publicChannels().publisher()
        ).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                print("Error", error)
            }
        }) { channelLists in
            self.channels = channelLists.0 + channelLists.1
        }
    }
}

#if DEBUG
    struct ChannelListPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelListPage(channels: nil)
            }
        }
    }
#endif
