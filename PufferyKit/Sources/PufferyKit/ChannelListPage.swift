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
    private var api: API { Current.api }

    @State var presentsSettings = false
    @State var presentsChannelCreation = false
    @State var shouldReload = PassthroughSubject<Void, FetchingError>()
    @State private var selectedAllChannels = UIDevice.current.model == "iPad"

    var body: some View {
        ZStack {
            List {
                Section {
                    NavigationLink(destination: ChannelDetailsPage(), isActive: self.$selectedAllChannels) {
                        Text("All")
                    }
                }

                Section(header: channelsHeader("Own Channels")) {
                    Fetching(loadOwnChannelsPublisher, empty: self.noChannelsFound()) { channels in
                        ForEach(channels) { channel in
                            NavigationLink(destination: ChannelDetailsPage(channel: channel)) {
                                Text(channel.title)
                            }
                        }
                    }
                }

                Section(header: channelsHeader("Shared Channels")) {
                    Fetching(loadSharedChannelsPublisher, empty: self.noChannelsFound()) { channels in
                        ForEach(channels) { channel in
                            NavigationLink(destination: ChannelDetailsPage(channel: channel)) {
                                Text(channel.title)
                            }
                        }
                    }
                }
            }.roundedListStyle()
        }
        .navigationBarTitle("Puffery")
        .navigationBarItems(trailing: settingsNavigationBarItem)
        .onAppear { Current.tracker.record("channels") }
    }

    func channelsHeader(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()

            Button(action: { self.presentsChannelCreation.toggle() }) {
                Image(systemName: "plus.circle").font(.body)
            }.sheet(isPresented: $presentsChannelCreation, onDismiss: shouldReload.send) {
                NavigationView {
                    ChannelCreationPage()
                }.navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }

    func noChannelsFound(_: String = "No Channels") -> some View {
        HStack {
            Spacer()
            Text("Keine Channels").opacity(0.5)
            Spacer()
        }
    }

    var settingsNavigationBarItem: some View {
        Button(action: { self.presentsSettings.toggle() }) {
            Image(systemName: "person.crop.circle").font(.system(size: 21))
        }.sheet(isPresented: $presentsSettings) {
            NavigationView {
                AppSettingsPage()
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }

    var loadOwnChannelsPublisher: AnyPublisher<[Channel], FetchingError> {
        shouldReload.prepend(())
            .flatMap(api.ownChannels().publisher)
            .eraseToAnyPublisher()
    }

    var loadSharedChannelsPublisher: AnyPublisher<[Channel], FetchingError> {
        shouldReload.prepend(())
            .flatMap(api.sharedChannels().publisher)
            .eraseToAnyPublisher()
    }
}

#if DEBUG
    struct ChannelListPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelListPage()
            }
        }
    }
#endif
