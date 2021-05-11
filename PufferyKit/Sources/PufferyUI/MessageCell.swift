//
//  MessageCell.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct MessageCell: View {
    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    let message: Message

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(message.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(messageDateDescription)
                        .font(.caption)
                        .foregroundColor(message.color.secondary)
                }

                Text(message.body)
                    .font(.subheadline)
                    .padding(.top, 6)
                    .onTapGestureOpenFirstURL(in: message.body)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .background(message.color)
        .foregroundColor(message.color.foregroundColor)
        .cornerRadius(15)
        .copyContextMenu(text: messageContent)
        .shadow(radius: 8)
    }
    
    var messageDateDescription: String {
        MessageCell.dateFormatter.localizedString(for: message.createdAt, relativeTo: Date())
    }

    var messageContent: String {
        """
        \(message.title)
        \(messageDateDescription)
        \(message.body)
        """
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

    public var foregroundColor: Color {
        .white
    }
    
    public var secondary: Color {
        Color(white: 1.0, opacity: 0.7)
    }
}

#if DEBUG
    struct MessageCell_Previews: PreviewProvider {
        static var previews: some View {
            MessageCell(message: .dockerImage)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
#endif

extension View {
    func copyContextMenu(text: String) -> some View {
        contextMenu(ContextMenu(menuItems: {
            Button(
                action: { UIPasteboard.general.string = text },
                label: { Text("Copy") }
            )
        }))
    }

    func onTapGestureOpenFirstURL(in text: String) -> some View {
        onTapGesture {
            guard let detector = try? NSDataDetector(
                    types: NSTextCheckingResult.CheckingType.link.rawValue
                ),
                let match = detector.firstMatch(
                    in: text,
                    options: [],
                    range: NSRange(location: 0, length: text.utf16.count)
                ),
                let range = Range(match.range, in: text),
                let url = URL(string: String(text[range]))
            else {
                return
            }
            UIApplication.shared.open(url)
        }
    }
}
