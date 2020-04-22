//
//  ChannelListView.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI

struct ChannelListView: View {
    @EnvironmentObject var api: API
    @State var channels: [Channel]?

    @State var presentsSettings = false
    @State var presentsChannelCreation = false

    @State var refreshSubscription: AnyCancellable? = nil

    var body: some View {
        ZStack {
            channels.map { channels in
                List {
                    Section {
                        NavigationLink(destination: ChannelDetailsView()) {
                            Text("All")
                        }
                    }
                    Section(header: channelsHeader) {
                        ForEach(channels) { channel in
                            NavigationLink(destination: ChannelDetailsView(channel: channel)) {
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
    }

    var channelsHeader: some View {
        HStack {
            Text("Channels")
            Spacer()

            Button(action: { self.presentsChannelCreation.toggle() }) {
                Image(systemName: "plus.circle").font(.body)
            }.sheet(isPresented: $presentsChannelCreation, onDismiss: loadChannels) {
                NavigationView {
                    ChannelCreationPage()
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
            }
        }
    }

    func loadChannels() {
        refreshSubscription = Publishers.Zip(
            api.privateChannels(device: latestDeviceToken).publisher(),
            api.publicChannels(device: latestDeviceToken).publisher()
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
    struct ChannelListView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelListView(channels: nil)
            }
        }
    }
#endif
