//
//  RichButtonStyle.swift
//
//
//  Created by Valentin Knabel on 03.05.20.
//

import SwiftUI

public struct RoundedButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                        .shadow(color: .white, radius: configuration.isPressed ? 7: 10, x: configuration.isPressed ? -5: -15, y: configuration.isPressed ? -5: -15)
                        .shadow(color: .black, radius: configuration.isPressed ? 7 : 10, x: configuration.isPressed ? 5 : 15, y: configuration.isPressed ? 5 : 15)
                        .blendMode(.overlay)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor)
//                        .blendMode(.hardLight)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

#if DEBUG
    struct RichButtonStyle_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                Spacer()
                Button(action: {}) {
                    Text("Button")
                }.buttonStyle(RoundedButtonStyle())
                Spacer()
            }
        }
    }
#endif
