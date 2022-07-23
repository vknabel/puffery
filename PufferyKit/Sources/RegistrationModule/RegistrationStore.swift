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
    public var latestOrLoginEmail = ""
    public var registerEmail = ""
    public var activity = ActivityState.idle

    public var shouldCheckEmails = false
    public var showsWelcomePage = false
    
    public init() {}

    public enum ActivityState: Equatable {
        case idle
        case inProgress
        case failed(FetchingError)

        public var inProgress: Bool {
            if case .inProgress = self {
                return true
            } else {
                return false
            }
        }

        public var failedError: FetchingError? {
            if case let .failed(error) = self {
                return error
            } else {
                return nil
            }
        }
    }
}

public enum RegistrationAction {
    case updateLoginEmail(String)
    case updateRegisterEmail(String)
    // TODO: remove onFinish
    case shouldRegister(onFinish: () -> Void)
    case shouldLogin(onFinish: () -> Void)

    case showCheckEmails(Bool)
    case showWelcomePage(Bool)

    case activityFinished
    case activityFailed(FetchingError)
    case activityErrorCleared
}

public let registrationReducer = Reducer<
    RegistrationState,
    RegistrationAction,
    RegistrationEnvironment
> { (state, action, environment: RegistrationEnvironment) in
    switch action {
    case let .updateLoginEmail(email):
        state.latestOrLoginEmail = email
        return .none
    case let .updateRegisterEmail(email):
        state.latestOrLoginEmail = email
        state.registerEmail = email
        return .none
    case let .showCheckEmails(shows):
        state.shouldCheckEmails = shows
        return .none
    case .showWelcomePage(false) where state.showsWelcomePage:
        state.showsWelcomePage = false
        return .init(value: .activityFinished)
    case let .showWelcomePage(shows):
        state.showsWelcomePage = shows
        return .none

    case .activityFinished:
        state.activity = .idle
        return .none
    case let .activityFailed(error):
        state.activity = .failed(error)
        return .none
    case .activityErrorCleared:
        state.activity = .idle
        return .none

    case let .shouldLogin(onFinish: onFinish):
        state.activity = .inProgress

        return environment.loginEffect(state.latestOrLoginEmail)
            .handleEvents(receiveOutput: onFinish)
            .flatMap { _ in
                [
                    RegistrationAction.activityFinished,
                    RegistrationAction.showCheckEmails(true),
                ].publisher.transformError(to: FetchingError.self)
            }
            .catch { fetchingError in
                Effect<RegistrationAction, Never>(value: RegistrationAction.activityFailed(fetchingError))
            }
            .eraseToEffect()

    case .shouldRegister where state.activity.inProgress:
        return .none

    case let .shouldRegister(onFinish: onFinish):
        state.activity = .inProgress

        return environment.registerEffect(state.registerEmail.isEmpty ? nil : state.registerEmail)
            .transform(to: RegistrationAction.showWelcomePage(true))
            .catch { fetchingError in
                Effect<RegistrationAction, Never>(value: RegistrationAction.activityFailed(fetchingError))
            }
            .eraseToEffect()
    }
}
