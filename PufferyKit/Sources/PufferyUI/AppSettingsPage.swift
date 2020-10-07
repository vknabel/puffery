//
//  AppSettingsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import PrivacyPolicyModule

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
            }
        }
        .roundedListStyle()
        .navigationBarTitle("Settings.Title", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: dismiss) {
            Text("Settings.Done").fontWeight(.bold)
        })
        .trackAppearence("settings", using: Current.tracker)
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func logout() {
        dismiss()
        DispatchQueue.main.async {
            Current.store.commit(.updateSession(nil))
        }
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
