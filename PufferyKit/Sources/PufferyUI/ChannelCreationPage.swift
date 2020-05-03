//
//  ChannelCreationPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 20.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import UserNotifications
import APIDefinition

struct ChannelCreationPage: View {
    @State var title: String = ""
    private var api: API { Current.api }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var isUUID: Bool {
        UUID(uuidString: title) != nil
    }

    var body: some View {
        Form {
            Section(footer: Text("CreateChannel.Basic.Explanation")) {
                TextField("CreateChannel.Basic.Title", text: $title, onCommit: createChannel)
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
            .onAppear { Current.tracker.record("channels/create") }
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

    func createChannel() {
        PushNotifications.register {
            if self.isUUID {
                self.api.subscribe(CreateSubscriptionRequest(receiveOrNotifyKey: self.title))
                    .task(self.receiveChannel(result:))
            } else {
                self.api.createChannel(CreateChannelRequest(title: self.title))
                    .task(self.receiveChannel(result:))
            }
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
