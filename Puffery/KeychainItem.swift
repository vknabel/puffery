//
//  KeychainItem.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import KeychainSwift

@propertyWrapper
struct KeychainItem {
    typealias Value = String
    
    private let keychain: KeychainSwift
    private let key: String
    private let access: KeychainSwiftAccessOptions?
    
    var wrappedValue: Value? {
        get { keychain.get(key) }
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: key, withAccess: access)
            } else {
                keychain.delete(key)
            }
        }
    }
    
    init(_ key: String, keychain: KeychainSwift, withAccess access: KeychainSwiftAccessOptions? = nil) {
        self.keychain = keychain
        self.key = key
        self.access = access
    }
}
