import Vapor

struct ApiError: Error, DebuggableError, AbortError {
    enum Reason: String {
        case notifyKeyDoesNotMatch
        case channelNotFound
        case invalidCredentials
    }

    var identifier: String {
        value.rawValue
    }

    var reason: String {
        switch value {
        case .channelNotFound:
            return "Channel not found"
        case .notifyKeyDoesNotMatch:
            return "Invalid notify key provided. Did you pick the receive only key?"
        case .invalidCredentials:
            return "Invalid credentials"
        }
    }

    var status: HTTPResponseStatus {
        switch value {
        case .channelNotFound:
            return .notFound
        case .notifyKeyDoesNotMatch:
            return .forbidden
        case .invalidCredentials:
            return .forbidden
        }
    }

    var value: Reason
    var source: ErrorSource?

    init(
        _ value: Reason,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.value = value
        source = .init(
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
}
