import APIDefinition
import Vapor

final class DeviceController {
    func create(_ req: Request) async throws -> DeviceResponse {
        let user = try req.auth.require(User.self)
        let createDevice = try req.content.decode(CreateDeviceRequest.self)
        let deviceToken = try DeviceToken(user: user, token: createDevice.token, isProduction: createDevice.isProduction ?? true)
        try await deviceToken.save(on: req.db)
        return try DeviceResponse(
            id: deviceToken.requireID(),
            token: deviceToken.token,
            isProduction: deviceToken.isProduction
        )
    }

    func createOrUpdate(_ req: Request) async throws -> DeviceResponse {
        let user = try req.auth.require(User.self)
        let deviceToken = req.parameters.get("device_token") ?? ""
        if deviceToken.isEmpty {
            throw Abort(.notFound)
        }

        let createDevice = try req.content.decode(CreateOrUpdateDeviceRequest.self)
        let existingToken = try await DeviceToken.query(on: req.db)
            .filter(\.$token, .equal, deviceToken)
            .first()

        let token: DeviceToken
        if let existingToken = existingToken {
            existingToken.$user.id = try user.requireID()
            existingToken.$user.value = user
            try await existingToken.update(on: req.db)
            token = existingToken
        } else {
            token = try DeviceToken(user: user, token: deviceToken, isProduction: createDevice.isProduction ?? true)
            try await token.save(on: req.db)
        }

        return try DeviceResponse(
            id: token.requireID(),
            token: token.token,
            isProduction: token.isProduction
        )
    }
}
