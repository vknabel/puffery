//
//  PufferyApp.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import PlatformSupport
import SwiftUI

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

enum DeepLinkedChannel: Identifiable {
    case channel(Channel)
    case allChannels

    var id: String {
        switch self {
        case let .channel(channel):
            return "channel:\(channel.id.uuidString)"
        case .allChannels:
            return "allChannels"
        }
    }

    var channel: Channel? {
        if case let .channel(channel) = self {
            return channel
        } else {
            return nil
        }
    }
}

struct PufferyApp: View {
    @State var cancellableSet = Set<AnyCancellable>()
    @State var deepLinkedChannel: DeepLinkedChannel?

    var body: some View {
        NavigationView {
            ChannelListPage()
            ChannelDetailsPage()
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(item: $deepLinkedChannel) { deepLink in
            NavigationView {
                ChannelDetailsPage(channel: deepLink.channel, displaysChannelSettings: false)
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
        .flatMap { notif -> AnyPublisher<DeepLinkedChannel?, Never> in
            guard let channelID = notif.channelID else {
                return Just(.allChannels).eraseToAnyPublisher()
            }
            return Current.api.channel(id: channelID)
                .publisher()
                .removeDuplicates(by: { $0.id == $1.id })
                .map(DeepLinkedChannel.channel)
                .map(Optional.some)
                .catch { _ in
                    Just(nil)
                }
                .eraseToAnyPublisher()
        }
}

#if DEBUG
    struct PufferyApp_Previews: PreviewProvider {
        static var previews: some View {
            SelectPufferyApp()
        }
    }
#endif
