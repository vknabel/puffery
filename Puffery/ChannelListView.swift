//
//  ChannelListView.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ChannelListView: View {
    var channels: [Channel]
    
    @State var presentsSettings = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: EmptyView()) {
                    Text("All")
                }
            }
            Section(header: Text("Channels")) {
                ForEach(channels) { channel in
                    NavigationLink(destination: ChannelDetailsView(channel: channel)) {
                        Text(channel.name)
                    }
                }
            }
        }
        .roundedListStyle()
        .navigationBarTitle("Inbox")
        .navigationBarItems(trailing: settingsNavigationBarItem)
    }
    
    var settingsNavigationBarItem: some View {
        Button(action: { self.presentsSettings.toggle() }) {
            Image(systemName: "wrench")
        }.sheet(isPresented: $presentsSettings) {
            NavigationView {
                AppSettingsPage()
            }
        }
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelListView(channels: [
                Channel(name: "Bitrise"),
                Channel(name: "Manual"),
            ])
        }
    }
}
