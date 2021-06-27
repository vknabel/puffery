//
//  AckeeTracker+SwiftUI.swift
//  
//
//  Created by Valentin Knabel on 27.06.21.
//

#if canImport(SwiftUI)

    import SwiftUI

    extension View {
        public func record(_ siteLocation: String) -> some View {
            AckeeTrackerView(attributes: CreateRecordInput(siteLocation: siteLocation), content: self)
        }
        
        public func record(_ attributes: CreateRecordInput) -> some View {
            AckeeTrackerView(attributes: attributes, content: self)
        }
    }

    fileprivate struct AckeeTrackerView<Content: View>: View {
        var attributes: CreateRecordInput
        var content: Content

        @State
        fileprivate var recorder: DurationRecorder? = nil

        var body: some View {
            content
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        self.recorder = ackeeTracker.recordPresence(attributes)
                    }
                })
                .onDisappear(perform: {
                    DispatchQueue.main.async {
                        self.recorder = nil
                    }
                })
        }
    }

#endif
