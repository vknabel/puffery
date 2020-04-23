//
//  AppSettingsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct AppSettingsPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var tokens: TokenRepository

    var body: some View {
        List {
            Section(header: Text("Notifications")) {
                Button(action: registerForPushNotifications) {
                    Text("Copy notification token")
                }
            }

            Section {
                NavigationLink(destination: AcknowledgementsPage()) {
                    Text("Acknowledgements")
                }
            }
        }
        .roundedListStyle()
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: dismiss) {
            Text("Done").fontWeight(.bold)
            })
    }

    func registerForPushNotifications() {
        PushNotifications.register {
            UIPasteboard.general.string = self.tokens.latestDeviceToken
        }
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
    struct AppSettingsPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                AppSettingsPage()
            }
        }
    }
#endif
