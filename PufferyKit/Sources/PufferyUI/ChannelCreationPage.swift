//
//  ChannelCreationPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 20.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import SwiftUI
import UserNotifications

struct ChannelCreationPage: View {
    @State var title: String = ""
    @State var receiveNotifications: Bool = PushNotifications.hasBeenRequested

    private var api: API { Current.api }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var isUUID: Bool {
        UUID(uuidString: title) != nil
    }

    var body: some View {
        Form {
            Section(footer: Text("CreateChannel.Basic.Explanation")) {
                TextField("CreateChannel.Basic.Title", text: $title, onCommit: createChannel)
                Toggle("CreateChannel.Basic.ReceiveNotifications", isOn: Binding(get: { self.receiveNotifications }, set: self.registerAndSetReceiveNotifications))
            }
            Section {
                Button(action: createChannel) {
                    Text(isUUID ? "CreateChannel.Actions.Subscribe" : "CreateChannel.Actions.Create")
                }.disabled(title.isEmpty)
            }
        }.navigationBarTitle("CreateChannel.Title", displayMode: NavigationBarItem.TitleDisplayMode.inline)
            .navigationBarItems(
                leading: cancelNavigationItem,
                trailing: createNavigationItem
            )
            .trackAppearence("channels/create", using: Current.tracker)
    }

    var createNavigationItem: some View {
        Button(action: createChannel) {
            Text(isUUID ? "CreateChannel.Actions.Subscribe" : "CreateChannel.Actions.Create").fontWeight(.bold)
        }
    }

    var cancelNavigationItem: some View {
        Button(action: dismiss) {
            Text("Cancel")
        }
    }

    func registerAndSetReceiveNotifications(_ newValue: Bool) {
        if newValue == true, !PushNotifications.hasBeenRequested {
            PushNotifications.register {
                self.receiveNotifications = newValue
            }
        } else {
            receiveNotifications = newValue
        }
    }

    func createChannel() {
        if isUUID {
            api.subscribe(CreateSubscriptionRequest(receiveOrNotifyKey: title, isSilent: !receiveNotifications))
                .task(receiveChannel(result:))
        } else {
            api.createChannel(CreateChannelRequest(title: title, isSilent: !receiveNotifications))
                .task(receiveChannel(result:))
        }
    }

    func receiveChannel(result: Result<SubscribedChannelResponse, FetchingError>) {
        switch result {
        case .success:
            dismiss()
        case let .failure(error):
            print("Error", error)
        }
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
    struct ChannelCreationPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelCreationPage()
            }
        }
    }
#endif
