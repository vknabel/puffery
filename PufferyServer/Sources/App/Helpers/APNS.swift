import APNS
import Vapor

public func apns(_ app: Application) throws {
    guard let keyID = Environment.get("APNS_KEY_ID"),
          let teamID = Environment.get("APNS_TEAM_ID"),
          let environment = try APNSwiftConfiguration.Environment(key: "APNS_ENVIRONMENT")
    else {
        app.logger.warning("Missing APNS_KEY_ID, APNS_TEAM_ID. Disabling notifications.")
        return
    }
    let keyPath = Environment.get("APNS_KEY_PATH") ?? "private/AuthKey_\(keyID).p8"

    app.apns.configuration = try APNSwiftConfiguration(
        authenticationMethod: .jwt(
            key: .private(filePath: keyPath),
            keyIdentifier: .init(string: keyID),
            teamIdentifier: teamID
        ),
        topic: "com.vknabel.puffery",
        environment: environment,
        logger: app.logger
    )
}

extension APNSwiftConfiguration.Environment {
    public init?(key: String) throws {
        switch Environment.get(key) {
        case "production":
            self = .production
        case "sandbox":
            self = .sandbox
        case let given?:
            throw UnsupportedAPNSEnvrionment(given: given)
        case nil:
            return nil
        }
    }

    private struct UnsupportedAPNSEnvrionment: Error {
        let given: String

        var localizedDescription: String {
            #"Unsupported APNS Envrionment: "\#(given)". Only supports "production" and "staging""#
        }
    }
}
