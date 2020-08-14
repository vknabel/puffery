//
//  PushNotifications.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import PufferyKit
import UserNotifications
#if canImport(UIKit)
    import UIKit
#endif

public enum PushNotifications {
    private static let hasBeenRequestedDefaultsKey = "PushNotifications.hasBeenRequestedDefaultsKey"
    public static var hasBeenRequested: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasBeenRequestedDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasBeenRequestedDefaultsKey)
        }
    }

    public static func register() {
        register {}
    }

    public static func register(_ onFinish: @escaping () -> Void) {
        hasBeenRequested = true
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, _ in
                print("Permission granted: \(granted)")
                guard granted else {
                    DispatchQueue.main.async {
                        onFinish()
                    }
                    return
                }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        #if targetEnvironment(simulator)
                            Current.store.commit(.updateDeviceToken(nil))
                        #elseif canImport(UIKit)
                            UIApplication.shared.registerForRemoteNotifications()
                        #else
                            Current.store.commit(.updateDeviceToken(nil))
                        #endif
                        onFinish()
                    }
                }
            }
    }
}
