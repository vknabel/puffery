//
//  ChannelSubscribingPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 01.05.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import SwiftUI
import UserNotifications
import PlatformSupport

struct ChannelSubscribingPage: View {
    @State var channelKey: String = ""
    @State var receiveNotifications: Bool = PushNotifications.hasBeenRequested
    private var api: API { Current.api }

    var isUUID: Bool {
        UUID(uuidString: channelKey) != nil
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Form {
            Section(footer: Text("ChannelSubscribing.Basic.Explanation")) {
                TextField("ChannelSubscribing.Basic.ChannelKey", text: $channelKey, onCommit: createChannel)
                Toggle("ChannelSubscribing.Basic.ReceiveNotifications", isOn: Binding(get: { self.receiveNotifications }, set: self.registerAndSetReceiveNotifications))
            }
            Section {
                Button(action: createChannel) {
                    Text("ChannelSubscribing.Subscribe")
                }.disabled(!isUUID)
            }
        }
        .navigationBarTitle("ChannelSubscribing.Title", displayMode: NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarItems(
            leading: cancelNavigationItem,
            trailing: createNavigationItem
        )
        .onAppear {
            if let subscription = UIPasteboard.general.strings?.compactMap(UUID.init(uuidString:)).first {
                self.channelKey = subscription.uuidString
            }
        }
    }

    var createNavigationItem: some View {
        Button(action: createChannel) {
            Text("ChannelSubscribing.Subscribe").fontWeight(.bold)
        }
    }

    var cancelNavigationItem: some View {
        Button(action: dismiss) {
            Text("ChannelSubscribing.Cancel")
        }
    }

    func registerAndSetReceiveNotifications(_ newValue: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        if newValue == true, !PushNotifications.hasBeenRequested {
            PushNotifications.register {
                self.receiveNotifications = newValue
            }
        } else {
            receiveNotifications = newValue
        }
    }

    func createChannel() {
        api.subscribe(CreateSubscriptionRequest(receiveOrNotifyKey: channelKey, isSilent: !receiveNotifications))
            .task(receiveChannel(result:))
    }

    func receiveChannel(result: Result<SubscribedChannelResponse, FetchingError>) {
        dispatchPrecondition(condition: .onQueue(.main))
        switch result {
        case .success:
            dismiss()
        case let .failure(error):
            print("Error", error)
        }
    }

    func dismiss() {
        dispatchPrecondition(condition: .onQueue(.main))
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
    struct ChannelSubscribingPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelSubscribingPage()
            }
        }
    }
#endif
