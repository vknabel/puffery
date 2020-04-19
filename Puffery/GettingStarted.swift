//
//  GettingStarted.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import UserNotifications

struct GettingStarted: View {
    var body: some View {
        Button(action: registerForPushNotifications) {
            Text("Copy Push notification token")
        }
    }
    
    func registerForPushNotifications() {
          UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
              granted, error in
              print("Permission granted: \(granted)") // 3
                
                guard granted else {
                    return
                }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                      UIApplication.shared.registerForRemoteNotifications()
                    }
                }
          }
    }
}

struct GettingStarted_Previews: PreviewProvider {
    static var previews: some View {
        GettingStarted()
    }
}
