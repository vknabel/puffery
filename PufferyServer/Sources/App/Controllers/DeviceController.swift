import Vapor

final class DeviceController {
    func create(_ req: Request) throws -> Future<DeviceResponse> {
        let user = try req.auth.require(User.self)
        let createDevice = try req.content.decode(CreateDeviceRequest.self)
        let deviceToken = try DeviceToken(user: user, token: createDevice.token, isProduction: createDevice.isProduction ?? true)
        return deviceToken
            .save(on: req.db)
            .transform(to: deviceToken)
            .flatMapThrowing { try DeviceResponse(id: $0.requireID(), token: $0.token, isProduction: $0.isProduction) }
    }

    func createOrUpdate(_ req: Request) throws -> Future<DeviceResponse> {
        let user = try req.auth.require(User.self)
        let deviceToken = req.parameters.get("device_token") ?? ""
        if deviceToken.isEmpty {
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }

        let createDevice = try req.content.decode(CreateOrUpdateDeviceRequest.self)
        return DeviceToken.query(on: req.db)
            .filter(\.$token, .equal, deviceToken)
            .first()
            .flatMap { (existingToken) -> Future<DeviceToken> in
                if let existingToken = existingToken {
                    existingToken.$user.id = try user.requireID()
                    existingToken.$user.value = user
                    return existingToken.update(on: req.db)
                        .transform(to: existingToken)
                } else {
                    let deviceToken = try DeviceToken(user: user, token: deviceToken, isProduction: createDevice.isProduction ?? true)
                    return deviceToken.save(on: req.db)
                        .transform(to: deviceToken)
                }
            }
            .flatMapThrowing { try DeviceResponse(id: $0.requireID(), token: $0.token, isProduction: $0.isProduction) }
    }
}
