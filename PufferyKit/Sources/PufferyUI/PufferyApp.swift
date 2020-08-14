//
//  PufferyApp.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI
import PlatformSupport

public struct SelectPufferyApp: View {
    @ObservedObject var store = Current.store

    public init() {}

    public var body: some View {
        ZStack {
            PufferyApp()
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
    @State var cancellableSet = Set<AnyCancellable>()
    @State var deepLinkedChannel: Channel?

    var body: some View {
        NavigationView {
            ChannelListPage()
            ChannelDetailsPage()
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(item: $deepLinkedChannel) { channel in
            NavigationView {
                ChannelDetailsPage(channel: channel, displaysChannelSettings: false)
            }
        }
        .onDisappear {
            self.cancellableSet = []
        }
        .onAppear {
            self.deepLinkedMessage
                .receive(on: RunLoop.main)
                .assign(to: \.deepLinkedChannel, on: self)
                .store(in: &self.cancellableSet)
        }
    }

    var deepLinkedMessage = NotificationCenter.default.publisher(for: .receivedMessage)
        .map { notif in
            notif.userInfo!["ReceivedMessageNotification"] as! ReceivedMessageNotification
        }
        .flatMap { notif in
            Current.api.channel(id: notif.subscribedChannelID)
                .publisher()
                .removeDuplicates(by: { $0.id == $1.id })
                .map(Optional.some)
                .catch { _ in
                    Just(nil)
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
