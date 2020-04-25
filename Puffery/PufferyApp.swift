//
//  PufferyApp.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

enum AppMode: Equatable {
    case gettingStarted
    case requiresPushNotifications
    case mainApp
    case loading
}

struct SelectPufferyApp: View {
    @State var mode = AppMode.loading
    @State var tokens: TokenRepository = Current.tokens

    var body: some View {
        ZStack {
            ActivityIndicator(isAnimating: mode == .loading)

            PufferyApp()
                .onAppear(perform: PushNotifications.register)
                .show(when: mode == .mainApp)
            GettingStartedPage(onFinish: determineCurrentNotificationSettings)
                .show(when: mode == .gettingStarted)
            Text("Requires Push Notifications").show(when: mode == .requiresPushNotifications)
        }.onAppear(perform: determineCurrentNotificationSettings)
    }

    func determineCurrentNotificationSettings() {
        guard !tokens.isLoggedIn else {
            mode = .mainApp
            return
        }
        mode = .gettingStarted
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
