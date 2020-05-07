//
//  TideAnimation.swift
//  
//
//  Created by Valentin Knabel on 07.05.20.
//

import SwiftUI

struct TideAnimation: ViewModifier {
    var duration: Double
    var offset: CGFloat
    @State var hasOffset = false
    
    @State var timer: Timer?

    func body(content: Content) -> some View {
        content
            .offset(x: hasOffset ? offset : 0, y: 0)
            .animation(.easeInOut(duration: duration))
            .onAppear {
                self.hasOffset.toggle()
                Timer.scheduledTimer(withTimeInterval: self.duration, repeats: true) { _ in
                    self.hasOffset.toggle()
                }
        }
    }
}
