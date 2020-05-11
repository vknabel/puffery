//
//  RegistrationEnvironment.swift
//  
//
//  Created by Valentin Knabel on 10.05.20.
//

import Foundation
import Combine
import ComposableArchitecture

public struct RegistrationEnvironment {
    public var loginEffect: (String) -> Effect<Void, FetchingError>
    public var registerEffect: (String?) -> Effect<TokenResponse, FetchingError>
}

extension RegistrationEnvironment {
    public static func live() -> RegistrationEnvironment {
        RegistrationEnvironment(
            loginEffect: RegistrationEnvironment.loginEffect,
            registerEffect: RegistrationEnvironment.registerEffect(email:))
    }
    
    private static func loginEffect(email: String) -> Effect<Void, FetchingError> {
        return registerPushNotificationsEffect()
            .transformError()
            .flatMap { token in
                Current.api.login(user: LoginUserRequest(
                    email: email,
                    device: token.map { CreateDeviceRequest(token: $0) }
                ))
                    .publisher()
                    .catch { error in
                        RegistrationEnvironment.registerOnLoginFailure(email: email, error: error)
                }
            }
            .eraseToEffect()
    }

    private static func registerEffect(email: String? = nil) -> Effect<TokenResponse, FetchingError> {
        return registerPushNotificationsEffect()
            .mapError { (_: Never) -> FetchingError in }
            .flatMap { (token: String?) -> AnyPublisher<TokenResponse, FetchingError> in
                let createDeviceRequest = token.map {
                    CreateDeviceRequest(token: $0)
                }
                return Current.api.register(user: CreateUserRequest(device: createDeviceRequest, email: email))
                    .publisher()
            }
            .eraseToEffect()
    }
    
    private static func registerPushNotificationsEffect() -> Effect<String?, Never> {
        Future { resolve in
            PushNotifications.register {
                resolve(.success(Current.store.state.session.latestDeviceToken))
            }
        }.eraseToEffect()
    }
    
    private static func registerOnLoginFailure(email: String, error: FetchingError) -> AnyPublisher<Void, FetchingError> {
        if error.reason.statusCode(403, 404) {
            return self.registerEffect(email: email)
                .map { _ in }
            .eraseToAnyPublisher()
        } else {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

extension Publisher {
    func transform<T>(to value: @autoclosure @escaping () -> T) -> Publishers.Map<Self, T> {
        map { _ in value() }
    }
}

extension Publisher where Failure == Never {
    func transformError<E: Error>(to errorType: E.Type = E.self) -> Publishers.MapError<Self, E> {
        mapError { (_: Never) -> E in }
    }
}
