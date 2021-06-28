//
//  ChangeProfilePage.swift
//  Puffery
//
//  Created by Valentin Knabel on 27.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import Combine
import SwiftUI
import DesignSystem
import PlatformSupport

struct ChangeProfilePage: View {
    @ObservedObject private var keyboard = Keyboard.shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var email = ""
    @State var inProgress = false

    var body: some View {
        Fetching(currentProfilePublisher) { profile in
            VStack {
                TextField(profile.email ?? NSLocalizedString("Profile.Email.Placeholder", comment: "Email"), text: self.$email, onCommit: self.performUpdate)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(self.inProgress)

                Button(action: self.performUpdate) {
                    Text(profile.email == nil || profile.email == "" ? LocalizedStringKey("Associate") : "Change")
                }
                .disabled(self.email.isEmpty)
                .buttonStyle(RoundedButtonStyle())
            }
            .padding()
            .padding(.bottom, self.keyboard.currentHeight)
            .animation(.default)
        }.navigationBarTitle("Profile.Email.Title")
        .record("profile")
    }

    var currentProfilePublisher: AnyPublisher<UserResponse, FetchingError> {
        Current.api.profile().publisher()
    }

    func performUpdate() {
        guard !email.isEmpty else {
            return
        }

        ackeeTracker.action(.session, key: .changeEmail)
        Current.api.updateProfile(credentials: UpdateProfileRequest(email: email.nonEmpty))
            .task { result in
                switch result {
                case .success:
                    self.dismiss()
                case let .failure(error):
                    print(error)
                }
            }
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
