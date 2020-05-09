//
//  PufferyApp.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

public struct SelectPufferyApp: View {
    @ObservedObject var store = Current.store

    public init() {}

    public var body: some View {
        ZStack {
            PufferyApp()
                .onAppear(perform: PushNotifications.register)
                .show(when: store.state.session.sessionToken != nil)

            GettingStartedPage(onFinish: determineCurrentNotificationSettings)
                .show(when: store.state.session.sessionToken == nil)
        }.onAppear(perform: determineCurrentNotificationSettings)
    }

    func determineCurrentNotificationSettings() {
//        guard !store.state.session.isLoggedIn() else {
//            mode = .mainApp
//            return
//        }
//        mode = .gettingStarted
//        mode = .loading
//
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            switch settings.authorizationStatus {
//            case .authorized, .provisional:
//                if self.tokens.latestDeviceToken != nil {
//                    self.mode = .mainApp
//                } else {
//                    PushNotifications.register {
//                        self.determineCurrentNotificationSettings()
//                    }
//                }
//            case .denied:
//                self.mode = .requiresPushNotifications
//            case .notDetermined:
//                self.mode = .gettingStarted
//            @unknown default:
//                self.mode = .gettingStarted
//            }
//        }
    }
}

struct PufferyApp: View {
    var body: some View {
        NavigationView {
            ChannelListPage()
        }
    }
}

extension View {
    func show(when predicate: Bool) -> some View {
        Group {
            if predicate {
                self
            }
        }
    }
}

#if DEBUG
    struct PufferyApp_Previews: PreviewProvider {
        static var previews: some View {
            SelectPufferyApp()
        }
    }
#endif
