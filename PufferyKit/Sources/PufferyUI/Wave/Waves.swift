//
//  Waves.swift
//
//
//  Created by Valentin Knabel on 07.05.20.
//

import Combine
import SwiftUI

struct Waves<Content: View>: View {
    let amplitude = 10.0
    @State var hasFish: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 0) {
                VStack {
                    Circle().fill(Color("LagoonBubbleBlue"))
                        .frame(height: 30)
                        .offset(x: proxy.size.width / 4, y: 0)
                        .modifier(SwimAnimation(duration: 7, offset: -5))
                    Circle().fill(Color("LagoonBubbleBlue"))
                        .frame(height: 25)
                        .offset(x: proxy.size.width / 8, y: 0)
                        .modifier(SwimAnimation(duration: 6, offset: 5))
                }.padding(.bottom)

                WaveShape(width: Double(proxy.size.width) + 50, step: 1, amplitude: 10) { x in
                    sin(x / 50 * .pi)
                }
                .foregroundColor(Color("LagoonLightBlue"))
                .modifier(TideAnimation(duration: 4.5, offset: 25))

                ZStack {
                    Color("LagoonLightBlue")

                    Circle().fill(Color("Background"))
                        .frame(height: 20)
                        .offset(x: proxy.size.width / 4, y: -40)
                        .modifier(SwimAnimation(duration: 5, offset: -5))

                    if self.hasFish {
                        Image("KugelfischAppTour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .transition(.slide)
                            .offset(x: -12, y: 25)
                            .modifier(SwimAnimation(duration: 3, offset: 5))
                    }
                }.frame(height: 150)
                    .zIndex(12)

                WaveShape(width: Double(proxy.size.width) + 50, step: 4, amplitude: 10) { x in
                    sin(x / 50 * .pi)
                }
                .foregroundColor(Color("LagoonLightBlue"))
                .scaleEffect(-1, anchor: .center)
                .modifier(TideAnimation(duration: 5, offset: -25))
                .zIndex(11)

                GeometryReader { gradientProxy in
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("LagoonGreen"),
                                Color("LogoonDeepBlue"),
                            ]),
                            startPoint: UnitPoint.bottomLeading,
                            endPoint: .topTrailing
                        )
                        self.content().zIndex(15).edgesIgnoringSafeArea([])
                    }
                    .frame(height: gradientProxy.size.height + CGFloat(2 * self.amplitude))
                    .offset(x: 0, y: CGFloat(-2 * self.amplitude))
                    .zIndex(10)
                }.edgesIgnoringSafeArea(.all)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
}

extension Waves {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.init(hasFish: true, content: content)
    }
}

struct Waves_Previews: PreviewProvider {
    static var previews: some View {
        Waves {
            Text("Example")
        }
    }
}
