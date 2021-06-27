//
//  DurationRecorder.swift
//  
//
//  Created by Valentin Knabel on 27.06.21.
//

import Foundation

@objc public class DurationRecorder: NSObject {
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

    @objc private func ping() {
        guard let record = record else {
            return
        }
        ackeeTracker.updateRecord(record)
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
