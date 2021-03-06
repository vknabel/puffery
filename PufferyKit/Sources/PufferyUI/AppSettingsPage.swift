//
//  AppSettingsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import PrivacyPolicyModule
import PlatformSupport
import RegistrationModule
import AckeeTracker

struct AppSettingsPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            Section(header: Text("Account")) {
                NavigationLink(destination: ChangeProfilePage()) {
                    Text("Settings.Account.ChangeEmail")
                }
            }

            Section {
                NavigationLink(
                    destination: WelcomePage(),
                    label: { Text("GettingStarted.Welcome.LetsStart") }
                )
                NavigationLink(destination: PrivacyPolicy()) {
                    Text("PrivacyPolicy.Title")
                }
                NavigationLink(destination: TermsAndConditions()) {
                    Text("TermsAndConditions.Title")
                }
                NavigationLink(destination: AcknowledgementsPage()) {
                    Text("Settings.Acknowledgements.Link")
                }
            }

            Section {
                Button(action: logout) {
                    Text("Settings.Session.Logout").foregroundColor(.red)
                }
                Button(action: deleteAccount) {
                    Text("Settings.Session.DeleteAccount").foregroundColor(.red)
                }
            }
        }
        .roundedListStyle()
        .navigationBarTitle("Settings.Title", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: dismiss) {
            Text("Settings.Done").fontWeight(.bold)
        })
        .record("settings")
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func logout() {
        ackeeTracker.action(.session, key: .logout)
        dismiss()
        DispatchQueue.main.async {
            Current.store.commit(.updateSession(nil))
            Widgets.reloadAll()
        }
    }

    func deleteAccount() {
        ackeeTracker.action(.session, key: .delete)
        dismiss()
        Current.api.deleteAccount()
            .task({ _ in
                DispatchQueue.main.async {
                    Current.store.commit(.updateSession(nil))
                    Widgets.reloadAll()
                }
            })?.resume()
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
