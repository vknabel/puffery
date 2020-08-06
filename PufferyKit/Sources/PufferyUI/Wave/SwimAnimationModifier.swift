//
//  SwimAnimationModifier.swift
//
//
//  Created by Valentin Knabel on 07.05.20.
//

import Combine
import SwiftUI

struct SwimAnimation: ViewModifier {
    var duration: Double
    var offset: CGFloat
    @State var hasOffset = false

    @State var timer: Timer?

    @State var isRotating = false
    @State var orientationChanges: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .offset(x: 0, y: hasOffset ? offset : 0)
            .animation(isRotating ? nil : .easeInOut(duration: duration))
            .onAppear {
                self.hasOffset.toggle()
                Timer.scheduledTimer(withTimeInterval: self.duration, repeats: true) { _ in
                    self.hasOffset.toggle()
                }
            }
            .onAppear {
                self.orientationChanges = sizeChangePublisher()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { _ in
                        self.isRotating = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isRotating = false
                        }
                    })
            }
    }
}
