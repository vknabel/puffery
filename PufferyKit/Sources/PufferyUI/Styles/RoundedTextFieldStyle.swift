//
//  RoundedTextFieldStyle.swift
//
//
//  Created by Valentin Knabel on 10.05.20.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
    @ObservedObject private var keyboard = Keyboard()

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.body
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("Background").opacity(keyboard.isActive ? 0.75 : 0.25))
            )
    }
}
