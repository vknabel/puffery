//
//  RegistrationViewModel.swift
//
//
//  Created by Valentin Knabel on 10.05.20.
//

import Combine
import ComposableArchitecture
import Foundation
import PufferyKit

public struct RegistrationState: Equatable {
    var email = ""
    var activity = ActivityState.idle

    var shouldCheckEmails = false
    
    public init() {}

    enum ActivityState: Equatable {
        case idle
        case inProgress
        case failed(FetchingError)

        var inProgress: Bool {
            if case .inProgress = self {
                return true
            } else {
                return false
            }
        }

        var failedError: FetchingError? {
            if case let .failed(error) = self {
                return error
            } else {
                return nil
            }
        }
    }
}

public enum RegistrationAction {
    case updateEmail(String)
    // TODO: remove onFinish
    case shouldRegister(onFinish: () -> Void)
    case shouldLogin(onFinish: () -> Void)

    case showCheckEmails(Bool)

    case activityFinished
    case activityFailed(FetchingError)
}

public let registrationReducer = Reducer<
    RegistrationState,
    RegistrationAction,
    RegistrationEnvironment
> { (state, action, environment: RegistrationEnvironment) in
    switch action {
    case let .updateEmail(email):
        state.email = email
        return .none
    case let .showCheckEmails(shows):
        state.shouldCheckEmails = shows
        return .none

    case .activityFinished:
        state.activity = .idle
        return .none
    case let .activityFailed(error):
        state.activity = .failed(error)
        return .none

    case let .shouldLogin(onFinish: onFinish):
        state.activity = .inProgress

        return environment.loginEffect(state.email)
            .handleEvents(receiveOutput: { onFinish() })
            .flatMap { _ in
                [
                    RegistrationAction.activityFinished,
                    RegistrationAction.showCheckEmails(true),
                ].publisher.transformError()
            }
            .catch { fetchingError in
                Effect<RegistrationAction, Never>(value: RegistrationAction.activityFailed(fetchingError))
            }
            .eraseToEffect()

    case .shouldRegister where state.activity.inProgress:
        return .none

    case let .shouldRegister(onFinish: onFinish):
        state.activity = .inProgress

        return environment.registerEffect(nil)
            .handleEvents(receiveOutput: { _ in onFinish() })
            .transform(to: RegistrationAction.activityFinished)
            .catch { fetchingError in
                Effect<RegistrationAction, Never>(value: RegistrationAction.activityFailed(fetchingError))
            }
            .eraseToEffect()
    }
}
