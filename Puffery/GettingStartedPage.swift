//
//  GettingStartedPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import UserNotifications

struct GettingStartedPage: View {
    var onFinish: () -> Void

    var body: some View {
        Button(action: registerForPushNotifications) {
            Text("Copy Push notification token")
        }.onAppear { Current.tracker.record("GettingStartedPage") }
    }

    func registerForPushNotifications() {
        PushNotifications.register(onFinish)
    }
}

#if DEBUG
    struct GettingStarted_Previews: PreviewProvider {
        static var previews: some View {
            GettingStartedPage(onFinish: {})
        }
    }
#endif
