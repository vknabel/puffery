import Foundation

/// Allows configuration of the Ackee Tracker.
/// Should be adjusted for your needs.
public struct AckeeConfiguration {
    /// The domain id of your application.
    public let domainId: String

    /// The url of your Ackee instance.
    public let serverUrl: URL

    /// The base URL used to prepend reported records.
    /// Note that you need to provide an actual domain.
    /// Just proividing an app scheme is not sufficient.
    public let appUrl: URL

    /// Disables all reporting.
    public let disabled: Bool

    /// Includes addition information about the user's system.
    public let detailed: Bool

    /// Creates a new Ackee Tracker configuration.
    ///
    /// - Parameters:
    ///     - domainId: The domain id of your application.
    ///     - serverUrl: The url of your Ackee instance.
    ///     - appUrl: The base URL used to prepend reported records.
    ///               Note that you need to provide an actual domain.
    ///               Just proividing an app scheme is not sufficient.
    ///     - disabled: Disables all reporting.
    ///     - detailed: Includes addition information about the user's system.
    public init(
        domainId: String,
        serverUrl: URL,
        appUrl: URL,
        disabled: Bool = false,
        detailed: Bool = false
    ) {
        self.domainId = domainId
        self.serverUrl = serverUrl
        self.appUrl = appUrl
        self.disabled = disabled
        self.detailed = detailed
    }
}
