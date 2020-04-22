//
//  ChannelCreationPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 20.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import UserNotifications

struct ChannelCreationPage: View {
    @State var title: String = ""
    @EnvironmentObject var api: API
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var isUUID: Bool {
        UUID(uuidString: title) != nil
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title)
            }
            Section {
                Button(action: createChannel) {
                    Text(isUUID ? "Join" : "Create")
                }.disabled(title.isEmpty)
            }
        }.navigationBarTitle("Create Channel", displayMode: NavigationBarItem.TitleDisplayMode.inline)
            .navigationBarItems(
                leading: cancelNavigationItem,
                trailing: createNavigationItem
            )
    }

    var createNavigationItem: some View {
        Button(action: dismiss) {
            Text(isUUID ? "Join" : "Create").fontWeight(.bold)
        }
    }

    var cancelNavigationItem: some View {
        Button(action: dismiss) {
            Text("Cancel")
        }
    }

    func createChannel() {
        registerForPushNotifications {
            if self.isUUID {
                self.api.subscribe(device: latestDeviceToken, publicChannel: self.title)
                    .task(self.receiveChannel(result:))
            } else {
                self.api.createChannel(title: self.title, deviceToken: latestDeviceToken)
                    .task(self.receiveChannel(result:))
            }
        }
    }

    func receiveChannel(result: Result<Void, FetchingError>) {
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

    func registerForPushNotifications(finish: @escaping () -> Void) {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, _ in
                print("Permission granted: \(granted)") // 3

                guard granted else {
                    return
                }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        finish()
                    }
                }
            }
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
