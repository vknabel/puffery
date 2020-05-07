//
//  WaveShape.swift
//  
//
//  Created by Valentin Knabel on 04.05.20.
//

import SwiftUI

struct WaveShape: View {
    let width: Double
    let step: Double
    let amplitude: Double

    @State var hasOffset = false
    
    let calc: (Double) -> Double
    
    var body: some View {
        Path { path in
            let height = amplitude * 2

            func y(_ x: Double) -> Double {
                self.calc(x) * amplitude
            }

            path.move(to: CGPoint(x: 0, y: y(0) + amplitude))
            for (fromX, toX) in stride(from: 0.0, through: width, by: step).pairwise() {
                let diff = toX - fromX
                let control1X = fromX + diff * 0.33
                let control2X = fromX + diff * 0.66
                path.addCurve(
                    to: CGPoint(x: toX, y: y(toX) + amplitude),
                    control1: CGPoint(x: control1X, y: y(control1X) + amplitude),
                    control2: CGPoint(x: control2X, y: y(control2X) + amplitude)
                )
            }
            path.addLines([
                CGPoint(x: width, y: y(width) + amplitude),
                CGPoint(x: width, y: height),
                CGPoint(x: 0, y: height),
                CGPoint(x: 0, y: y(0) + amplitude)
            ])
        }
            .frame(width: CGFloat(width), height: CGFloat(amplitude) * 2)
    }
}

extension Sequence {
    fileprivate func pairwise() -> AnySequence<(Element, Element)> {
        return AnySequence<(Element, Element)> { () -> AnyIterator<(Element, Element)> in
            var iterator = self.makeIterator()
            var previous = iterator.next()
            return AnyIterator { () -> (Element, Element)? in
                guard let current = previous, let next = iterator.next() else {
                    return nil
                }
                defer { previous = next }
                return (current, next)
            }
        }
    }
}

struct Wave_Previews: PreviewProvider {
    static var previews: some View {
        WaveShape(width: 100.0 + 50, step: 50 / 8.0, amplitude: 10) { x in
            sin(x / 50 * .pi)
        }
    }
}
