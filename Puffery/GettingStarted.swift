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
    var onFinish: () -> Void

    var body: some View {
        Button(action: registerForPushNotifications) {
            Text("Copy Push notification token")
        }
    }

    func registerForPushNotifications() {
        PushNotifications.register(onFinish)
    }
}

#if DEBUG
    struct GettingStarted_Previews: PreviewProvider {
        static var previews: some View {
            GettingStarted(onFinish: {})
        }
    }
#endif
