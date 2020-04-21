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

    var body: some View {
        ZStack {
            ActivityIndicator(isAnimating: mode == .loading)

            PufferyApp().show(when: mode == .mainApp)
            GettingStarted(onFinish: determineCurrentNotificationSettings)
                .show(when: mode == .gettingStarted)
            Text("Requires Push Notifications").show(when: mode == .requiresPushNotifications)
        }.onAppear(perform: determineCurrentNotificationSettings)
    }

    func determineCurrentNotificationSettings() {
        mode = .loading

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                self.mode = .mainApp
            case .denied:
                self.mode = .requiresPushNotifications
            case .notDetermined:
                self.mode = .gettingStarted
            @unknown default:
                self.mode = .gettingStarted
            }
        }
    }
}

struct PufferyApp: View {
    var body: some View {
        NavigationView {
            ChannelListView()
        }
    }
}

extension View {
    func show(when predicate: Bool) -> some View {
        Group {
            if predicate {
                self
            } else {
                hidden()
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
