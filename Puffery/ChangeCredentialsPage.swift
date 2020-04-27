//
//  ChangeCredentialsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 27.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI

struct ChangeCredentialsPage: View {
    @State var email = ""
    @State var password = ""
    @State var passwordRepeat = ""

    @State var oldPassword = ""

    var body: some View {
        Fetching(currentProfilePublisher) { profile in
            VStack {
                TextField("E-Mail", text: self.$email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                TextField("Password", text: self.$password)
                    .textContentType(.password)
                TextField("Password Repeat", text: self.$passwordRepeat)
                    .textContentType(.password)

                TextField("Old Password", text: self.$oldPassword)
                    .textContentType(.password)
                Button(action: self.performUpdate) {
                    Text("Login")
                }.disabled(self.email.isEmpty && self.password.count < 8 || self.oldPassword.isEmpty && profile.email != nil || self.password != self.passwordRepeat)
            }
        }.navigationBarTitle("Edit Profile")
    }

    var currentProfilePublisher: AnyPublisher<UserResponse, FetchingError> {
        Current.api.profile().publisher()
    }

    func performUpdate() {
        Current.api.updateProfile(credentials: UpdateCredentialsRequest(
            email: email.nonEmpty,
            password: password.nonEmpty,
            oldPassword: oldPassword.nonEmpty
        )).task { _ in
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
