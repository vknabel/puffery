//
//  TokenRepository.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import KeychainSwift
import Overture

final class TokenRepository: ObservableObject {
    private static let device: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, false))
    private static let cloud: KeychainSwift = update(KeychainSwift(), mut(\.synchronizable, true))

    @KeychainItem("latestDeviceToken", keychain: device)
    var latestDeviceToken: String? {
        willSet {
            objectWillChange.send()
        }
    }

    @KeychainItem("sessionToken", keychain: cloud)
    var sessionToken: String? {
        willSet {
            objectWillChange.send()
            print("update sessionToken", sessionToken, newValue)
        }
    }
    
    var isLoggedIn: Bool {
        sessionToken != nil
    }
}
