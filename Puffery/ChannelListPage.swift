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
        Fetching(loadChannelsPublisher, empty: self.channelsHeader) { channels in
            List {
                Section {
                    NavigationLink(destination: ChannelDetailsPage(), isActive: self.$selectedAllChannels) {
                        Text("All")
                    }
                }
                Section(header: self.channelsHeader) {
                    ForEach(channels) { channel in
                        NavigationLink(destination: ChannelDetailsPage(channel: channel)) {
                            Text(channel.title)
                        }
                    }
                }
            }
            .roundedListStyle()
        }
        .navigationBarTitle("Puffery")
        .navigationBarItems(trailing: settingsNavigationBarItem)
        .onAppear { Current.tracker.record("channels") }
    }

    var channelsHeader: some View {
        HStack {
            Text("Channels")
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

    var settingsNavigationBarItem: some View {
        Button(action: { self.presentsSettings.toggle() }) {
            Image(systemName: "person.crop.circle")
                .padding()
        }.sheet(isPresented: $presentsSettings) {
            NavigationView {
                AppSettingsPage()
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }

    var loadChannelsPublisher: AnyPublisher<[Channel], FetchingError> {
        shouldReload.prepend(())
            .flatMap(api.channels().publisher)
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
