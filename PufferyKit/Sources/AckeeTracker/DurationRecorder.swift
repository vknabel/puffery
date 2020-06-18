import Foundation

@objc public class DurationRecorder: NSObject {
    private let server: AckeeServer
    private var sessionTimer: Timer?
    internal var record: Record? {
        didSet {
            DispatchQueue.main.async {
                self.sessionTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                    self?.ping()
                }
            }
        }
    }

    internal init(server: AckeeServer) {
        self.server = server
    }

    @objc private func ping() {
        guard let record = record else {
            return
        }
        server.update(record: record)
    }

    public func cancel() {
        sessionTimer?.invalidate()
    }

    deinit {
        cancel()
    }
}

#if canImport(Combine)
    import Combine

    extension DurationRecorder: Cancellable {}
#endif
