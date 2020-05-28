import APNS
import Vapor

public func apns(_ app: Application) throws {
    guard let keyID = Environment.get("APNS_KEY_ID"),
        let teamID = Environment.get("APNS_TEAM_ID") else {
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
        environment: .production,
        logger: app.logger
    )
}
