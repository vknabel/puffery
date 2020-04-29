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

    var body: some View {
        Fetching(currentProfilePublisher) { profile in
            VStack {
                TextField(profile.email ?? "E-Mail", text: self.$email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)

                Button(action: self.performUpdate) {
                    Text("Update")
                }.disabled(self.email.isEmpty)
            }
        }.navigationBarTitle("Edit Profile")
    }

    var currentProfilePublisher: AnyPublisher<UserResponse, FetchingError> {
        Current.api.profile().publisher()
    }

    func performUpdate() {
        Current.api.updateProfile(credentials: UpdateCredentialsRequest(
            email: email.nonEmpty)).task { _ in
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
