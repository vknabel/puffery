//
//  RoundedTextFieldStyle.swift
//
//
//  Created by Valentin Knabel on 10.05.20.
//

import SwiftUI
import PlatformSupport

public struct RoundedTextFieldStyle: TextFieldStyle {
    @ObservedObject private var keyboard = Keyboard()
    
    public init() {}

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.body
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(keyboard.isActive ? 0.75 : 0.25))
            )
    }
}
