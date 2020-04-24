import APNS
import Vapor

public func apns(_ app: Application) throws {
    let keyID = Environment.get("APNS_KEY_ID")!
    let teamID = Environment.get("APNS_TEAM_ID")!
    let keyPath = Environment.get("APNS_KEY_PATH") ?? "private/AuthKey_\(keyID).p8"

    app.apns.configuration = try APNSwiftConfiguration(
        authenticationMethod: .jwt(
            key: .private(filePath: keyPath),
            keyIdentifier: .init(string: keyID),
            teamIdentifier: teamID
        ),
        topic: "com.vknabel.puffery",
        environment: .production
    )
}
