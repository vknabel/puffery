#if canImport(SwiftUI)

    import SwiftUI

    extension View {
        public func trackAppearence(_ location: String, using tracker: Tracker) -> some View {
            AckeeTrackerView(location: location, tracker: tracker, content: self)
        }
    }

    fileprivate struct AckeeTrackerView<Content: View>: View {
        var location: String
        var tracker: Tracker
        var content: Content

        @State
        fileprivate var recorder: DurationRecorder? = nil

        var body: some View {
            content
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        self.recorder = self.tracker.recordPresence(self.location)
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
