import Foundation

public final class DurationRecorder {
  private let server: AckeeServer
  private var sessionTimer: Timer?
  internal var record: Record? {
    didSet {
      sessionTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
        self?.ping()
      }
    }
  }
  
  internal init(server: AckeeServer) {
    self.server = server
  }
    
  private func ping() {
    guard let record = record else {
      return
    }
    server.update(record: record)
  }
    
  public func cancel() {
    
  }
  
  deinit {
    sessionTimer?.invalidate()
  }
}

#if canImport(Combine)
import Combine

extension DurationRecorder: Cancellable {}
#endif
