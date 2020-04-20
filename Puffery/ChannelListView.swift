//
//  ChannelListView.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ChannelListView: View {
    @State var channels: [Channel]

    @State var presentsSettings = false
    @State var presentsChannelCreation = false

    var body: some View {
        List {
            Section {
                NavigationLink(destination: EmptyView()) {
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
        ApiController().channels(deviceToken: latestDeviceToken) { result in
            switch result {
            case let .success(channels):
                self.channels = channels
            case let .failure(error):
                print("Error", error)
            }
        }
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelListView(channels: [
                .plants,
                .puffery,
            ])
        }
    }
}
