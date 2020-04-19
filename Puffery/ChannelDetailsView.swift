//
//  ChannelDetailsView.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ChannelDetailsView: View {
    var channel: Channel
    @State var messages: [Message]?
    @State var displaysChannelSettings = false
    
    var body: some View {
        ZStack {
            messages.map(MessageList.init(messages:))
            ActivityIndicator(isAnimating: messages == nil)
                .onAppear(perform: self.loadMessages)
            
        }
            .navigationBarTitle(self.channel.name)
            .navigationBarItems(trailing:
                Button(action: { self.displaysChannelSettings.toggle() }) {
                        Image(systemName: "wrench")
                            .sheet(isPresented: self.$displaysChannelSettings) {
                                NavigationView {
                                    ChannelSettingsPage(channel: self.channel)
                                }
                    }
                }
        )
    }
    
    private func loadMessages() {
        messages = [.dockerImage, .testflight]
    }
}

struct ChannelDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelDetailsView(channel: Channel(name: "Puffery"))
        }
    }
}

