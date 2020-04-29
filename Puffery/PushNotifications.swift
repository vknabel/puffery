//
//  PushNotifications.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

enum PushNotifications {
    static func register() {
        register {}
    }

    static func register(_ onFinish: @escaping () -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        #if targetEnvironment(simulator)
                        Current.store.commit(.updateDeviceToken(nil))
                        #else
                            UIApplication.shared.registerForRemoteNotifications()
                        #endif
                        onFinish()
                    }
                }
            }
    }
}
