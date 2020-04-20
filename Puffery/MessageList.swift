//
//  MessageList.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct MessageList: View {
    let messages: [Message]

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                ForEach(messages) { message in
                    MessageCell(message: message)
                }
            }
            .padding()
        }
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(messages: [
            Message(
                title: "New TestFlight version available",
                channel: .puffery,
                color: .orange
            ),
            Message(
                title: "New Docker image pushed",
                channel: .puffery,
                color: .blue
            ),
        ])
    }
}
