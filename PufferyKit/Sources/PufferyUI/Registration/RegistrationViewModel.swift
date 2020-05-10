//
//  RegistrationViewModel.swift
//
//
//  Created by Valentin Knabel on 10.05.20.
//

import Foundation

final class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var inProgress = false
    @Published var registrationError: FetchingError?
    @Published var shouldCheckEmails = false

    func shouldLogin(_ onFinish: @escaping () -> Void) {
        guard !email.isEmpty else {
            return
        }
        inProgress = true

        PushNotifications.register {
            let createDeviceRequest = Current.store.state.session.latestDeviceToken.map {
                CreateDeviceRequest(token: $0)
            }
            Current.api.login(user: LoginUserRequest(
                email: self.email,
                device: createDeviceRequest
            )).task { result in
                switch result {
                case .success:
                    self.inProgress = false
                    self.shouldCheckEmails = true
                case let .failure(error) where error.reason.statusCode(403, 404):
                    Current.api.register(user: CreateUserRequest(device: createDeviceRequest, email: self.email))
                        .task {
                            self.handleRegister(result: $0, onFinish: onFinish)
                        }
                case let .failure(error):
                    self.registrationError = error
                    self.inProgress = false
                }
            }
        }
    }

    func shouldRegister(_ onFinish: @escaping () -> Void) {
        guard !email.isEmpty else {
            return
        }
        registrationError = nil
        inProgress = true

        PushNotifications.register {
            let createDeviceRequest = Current.store.state.session.latestDeviceToken.map {
                CreateDeviceRequest(token: $0)
            }
            Current.api.register(user: CreateUserRequest(device: createDeviceRequest))
                .task {
                    self.handleRegister(result: $0, onFinish: onFinish)
                }
        }
    }

    private func handleRegister(result: Result<TokenResponse, FetchingError>, onFinish: @escaping () -> Void) {
        switch result {
        case .success:
            registrationError = nil
            DispatchQueue.main.async {
                onFinish()
            }
        case let .failure(error):
            inProgress = false
            registrationError = error
        }
    }
}
