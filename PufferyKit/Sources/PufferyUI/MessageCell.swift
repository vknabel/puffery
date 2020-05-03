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
        .foregroundColor(message.color.foregroundColor)
        .cornerRadius(15)
        .shadow(radius: 8)
    }
}

extension Message.Color: View {
    public var body: some View {
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
        case .pink:
            return SwiftUI.Color.pink
        case .purple:
            return SwiftUI.Color.purple
        case .yellow:
            return SwiftUI.Color.yellow
        }
    }
    
    var foregroundColor: Color? {
        .white
    }
}

#if DEBUG
    struct MessageCell_Previews: PreviewProvider {
        static var previews: some View {
            MessageCell(message: .dockerImage)
        }
    }
#endif
