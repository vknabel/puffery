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

                SelectableTextView(message.body, font: UIFont.preferredFont(forTextStyle: .subheadline))
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .background(message.color)
        .foregroundColor(message.color.foregroundColor)
        .cornerRadius(15)
        .shadow(radius: 8)
    }
    
    var messageDateDescription: String {
        MessageCell.dateFormatter.localizedString(for: message.createdAt, relativeTo: Date())
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
        }
    }
#endif

struct SelectableTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    var text: String
    var font: UIFont

    init(_ text: String, font: UIFont) {
        self.text = text
        self.font = font
    }

    func makeUIView(context _: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.text = text
        textView.font = font
        textView.textColor = .white
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textField.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    func updateUIView(_: UITextView, context _: Context) {
//        uiView.text = text
//        uiView.font = font
//        let fixedWidth = uiView.frame.size.width
//        let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    }
}
