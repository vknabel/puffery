import Foundation

/// The Ackee Tracker to be used across your app.
/// Prefer using this protocol instead of the concrete `AckeeTracker` implementation.
public protocol Tracker {
    /// Creates a new record on the server to track the visit.
    ///
    /// Typically names of your `ViewController`s will be provided here.
    /// Alternatively you could provide deep linking URLs to directly access contents from within your Ackee instance.
    ///
    /// ```
    /// ackee.record("MyController")
    /// ackee.record("deep/linking/url")
    /// ```
    ///
    /// - Parameters:
    ///     - location: The current site that should be reported.
    func record(_ location: String)
    /// Creates a new record on the server and updates the record constantly to track the duration of the visit.
    /// The update of old records will be canceled you cancel the returned duration recorder.
    ///
    /// Typically names of your `ViewController`s will be provided here.
    /// Alternatively you could provide deep linking URLs to directly access contents from within your Ackee instance.
    ///
    /// ```
    /// ackee.record("MyController")
    /// ackee.record("deep/linking/url")
    /// ```
    ///
    /// - Parameters:
    ///     - location: The current site that should be reported.
    func recordPresence(_ location: String) -> DurationRecorder
}

/// The production Ackee Tracker implementation.
/// Note that you need to provide an actual domain.
/// Just proividing an app scheme is not sufficient.
/// ```
/// let ackee: Tracker = AckeeTracker(
///     configuration: AckeeConfiguration(
///         domainId: "<your-domain-id>",
///         serverUrl: URL(string: "https://ackee.electerious.com")!,
///         // requires an actual host url!
///         appUrl: URL(string: "yourapp://some.domain")!
///     )
/// )
/// ```
public final class AckeeTracker: Tracker {
    fileprivate let configuration: AckeeConfiguration
    private let dependencies: AckeeDependencies
    private let server: AckeeServer

    /// Creates an Ackee Tracker for production.
    ///
    /// - Parameters:
    ///     - configuration: The configuration of URLs and domain ids.
    ///     - dependencies: When required, you can override internally used mechanisms.
    public init(
        configuration: AckeeConfiguration,
        dependencies: AckeeDependencies = .prod()
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
        server = AckeeServer(configuration: configuration, dependencies: dependencies)
    }

    public func record(_ location: String) {
        server.post(attributes: attributes(for: location)) { _ in }
    }

    public func recordPresence(_ location: String) -> DurationRecorder {
        let recordSession = DurationRecorder(server: server)
        server.post(attributes: attributes(for: location)) { record in
            recordSession.record = record
        }
        return recordSession
    }
}

#if canImport(UIKit)
    import UIKit
#endif

private extension AckeeTracker {
    func attributes(for location: String) -> Attributes {
        let siteLocation = configuration.appUrl.appendingPathComponent(location).absoluteString

        guard configuration.detailed else {
            return Attributes(siteLocation: siteLocation)
        }
        let siteLanguage: String? = Locale.current.languageCode
        let deviceName: String?
        #if canImport(UIKit)
            deviceName = UIDevice.current.model
        #endif

        let osName: String?
        #if os(macOS)
            osName = "OS X"
        #elseif os(iOS)
            osName = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #elseif os(watchOS)
            osName = "watchOS"
        #elseif os(tvOS)
            osName = "tvOS"
        #elseif os(Linux)
            osName = "Linux"
        #elseif os(Windows)
            osName = "Windows"
        #else
            osName = nil
        #endif

        let osVersion: String
        #if canImport(UIKit)
            osVersion = UIDevice.current.systemVersion
        #else
            let version = ProcessInfo.processInfo.operatingSystemVersion
            osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #endif

        return Attributes(
            siteLocation: siteLocation,
            siteLanguage: siteLanguage,
            deviceName: deviceName,
            osName: osName,
            osVersion: osVersion
        )
    }
}
