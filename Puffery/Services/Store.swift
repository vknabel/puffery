import Foundation
import KeychainSwift
import Overture
import Combine

var subscription: AnyObject?

final class Store: ObservableObject {
    let objectWillChange: ObservableObjectPublisher = ObservableObjectPublisher()
    
    fileprivate(set) var state = GlobalState() {
        willSet {
            objectWillChange.send()
        }
    }

    init() {
        state.session.latestDeviceToken = deviceKeychain.get("latestDeviceToken")
        state.session.sessionToken = cloudKeychain.get("sessionToken")
        
        subscription = self.objectWillChange.sink(receiveValue: { print("updated", self.state) })
    }

    private let deviceKeychain: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, false))
    private let cloudKeychain: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, true))
}

enum GlobalCommit {
    case updateDeviceToken(String?)
    case updateSession(TokenResponse?)
}

struct GlobalState {
    var session = Session()
    
//    var channels = [Channel]()
//    var messages = [Message]()
}

struct Session: Equatable {
    var latestDeviceToken: String?
    var sessionToken: String?
    var profile: UserResponse?
    
    func isLoggedIn() -> Bool {
        sessionToken != nil
    }
}

extension Store {
    func commit(_ action: GlobalCommit) {
//        DispatchQueue.main.async {
            self.commitOnMain(action)
//        }
    }
    
    private func commitOnMain(_ action: GlobalCommit) {
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
