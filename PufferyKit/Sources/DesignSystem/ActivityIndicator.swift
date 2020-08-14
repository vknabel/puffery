//
//  ActivityIndicator.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
    import UIKit

    public struct ActivityIndicator: UIViewRepresentable {
        typealias Style = UIActivityIndicatorView.Style
        var isAnimating: Bool
        var style: Style = .medium

        public func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
            let indicator = UIActivityIndicatorView(style: style)
            indicator.hidesWhenStopped = true
            return indicator
        }

        public func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        }
    }

    struct UIActivityIndicator_Previews: PreviewProvider {
        static var previews: some View {
            ActivityIndicator(isAnimating: true, style: .large)
        }
    }
#else
    public struct ActivityIndicator: UIView {
        public enum Style {
            case medium, large
        }

        var isAnimating: Bool
        var style: Style = .medium

        public var body: some View {
            Text("...")
        }
    }

    struct TextActivityIndicator_Previews: PreviewProvider {
        static var previews: some View {
            ActivityIndicator(isAnimating: true, style: .large)
        }
    }
#endif
