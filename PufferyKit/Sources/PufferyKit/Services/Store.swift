import APIDefinition
import Combine
import Foundation
import KeychainSwift
import Overture

var subscription: AnyObject?

public final class Store: ObservableObject {
    public let objectWillChange: ObservableObjectPublisher = ObservableObjectPublisher()

    public fileprivate(set) var state = GlobalState() {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    public init() {
        state.session.latestDeviceToken = deviceKeychain.get("latestDeviceToken")
        state.session.sessionToken = cloudKeychain.get("sessionToken")
    }

    private let deviceKeychain: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, false), mut(\.accessGroup, "BG9UY79792.com.vknabel.puffery.shared"))
    private let cloudKeychain: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, true), mut(\.accessGroup, "BG9UY79792.com.vknabel.puffery.shared"))
}

public enum GlobalCommit {
    case updateDeviceToken(String?)
    case updateSession(TokenResponse?)
}

public struct GlobalState {
    public var session = Session()

//    var channels = [Channel]()
//    var messages = [Message]()
}

public struct Session: Equatable {
    public var latestDeviceToken: String?
    public var sessionToken: String?
    public var profile: UserResponse?

    public func isLoggedIn() -> Bool {
        sessionToken != nil
    }
}

extension Store {
    public func commit(_ action: GlobalCommit) {
        if Thread.isMainThread {
            commitOnMain(action)
        } else {
            DispatchQueue.main.async {
                self.commitOnMain(action)
            }
        }
    }

    private func commitOnMain(_ action: GlobalCommit) {
        dispatchPrecondition(condition: .onQueue(.main))
        print("Action:", action)
        switch action {
        case .updateDeviceToken(nil):
            deviceKeychain.delete("latestDeviceToken")
            state.session.latestDeviceToken = nil
        case let .updateDeviceToken(token?):
            deviceKeychain.set(token, forKey: "latestDeviceToken")
            state.session.latestDeviceToken = token

        case .updateSession(nil):
            cloudKeychain.delete("sessionToken")
            state.session.sessionToken = nil
            state.session.profile = nil

        case let .updateSession(token?):
            cloudKeychain.set(token.token, forKey: "sessionToken")
            state.session.sessionToken = token.token
            state.session.profile = token.user
        }
    }
}
