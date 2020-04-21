//
//  MessageCell.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct MessageCell: View {
    let message: Message

    var body: some View {
        HStack {
//            message.sender.icon.imageView
            VStack(alignment: .leading) {
                Text(message.title)
                    .font(.headline)
                Text(message.body)
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .background(message.color)
        .colorScheme(ColorScheme.dark)
        .cornerRadius(15)
        .shadow(radius: 8)
    }
}

extension Message.Color: View {
    var body: some View {
        switch self {
        case .blue:
            return SwiftUI.Color.blue
        case .green:
            return SwiftUI.Color.green
        case .orange:
            return SwiftUI.Color.orange
        case .red:
            return SwiftUI.Color.red
        case .gray:
            return SwiftUI.Color.gray
        }
    }
}

#if DEBUG
    struct MessageCell_Previews: PreviewProvider {
        static var previews: some View {
            MessageCell(message: .dockerImage)
        }
    }
#endif
