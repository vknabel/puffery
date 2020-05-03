//
//  ChangeProfilePage.swift
//  Puffery
//
//  Created by Valentin Knabel on 27.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import SwiftUI
import APIDefinition

struct ChangeProfilePage: View {
    @State var email = ""

    var body: some View {
        Fetching(currentProfilePublisher) { profile in
            VStack {
                TextField(profile.email ?? NSLocalizedString("Profile.Email.Placeholder", comment: "Email"), text: self.$email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)

                Button(action: self.performUpdate) {
                    Text("Update")
                }.disabled(self.email.isEmpty)
            }
        }.navigationBarTitle("Profile.Email.Title")
    }

    var currentProfilePublisher: AnyPublisher<UserResponse, FetchingError> {
        Current.api.profile().publisher()
    }

    func performUpdate() {
        Current.api.updateProfile(credentials: UpdateProfileRequest(
            email: email.nonEmpty)).task { _ in
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
