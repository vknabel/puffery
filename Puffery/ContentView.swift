//
//  ContentView.swift
//  Puffery
//
//  Created by Valentin Knabel on 13.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ReceivedMessage: Identifiable {
    var id: UUID = UUID()

    var title: String
    var sender: Sender // TODO: Later more
    var triggerDate: Date
}

enum Icon {
    case computer
}

extension Icon {
    var imageView: some View {
        switch self {
        case .computer:
            return Image(systemName: "desktopcomputer")
        }
    }
}

struct Sender {
    var name: String
    var icon: Icon
}

let terminalSender = Sender(name: "My MacBook", icon: .computer)

struct AppView: View {
    let messages = [
        ReceivedMessage(title: "Build completed", sender: terminalSender, triggerDate: .init(timeIntervalSinceNow: -100)),
    ]

    var body: some View {
        TabView {
            MessagesView(messages: messages).tabItem {
                Image(systemName: "tray")
                Text("Messages")
            }

            Text("Create new x")
                .multilineTextAlignment(.center)
                .tabItem {
                    Image(systemName: "arrow.up.right.diamond")
                    Text("Senders")
                }
        }
    }
}

struct MessagesView: View {
    let messages: [ReceivedMessage]

    var body: some View {
        List(messages) { message in
            HStack {
                message.sender.icon.imageView
                VStack(alignment: .leading) {
                    Text(message.title)
                    Text(message.sender.name)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
