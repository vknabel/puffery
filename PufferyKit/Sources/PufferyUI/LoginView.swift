//
//  LoginView.swift
//  Puffery
//
//  Created by Valentin Knabel on 27.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import APIDefinition

struct LoginView: View {
    var onFinish: () -> Void

    @State var email = ""
    @State var logginIn = false

    var body: some View {
        VStack {
            TextField("E-Mail", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .disabled(logginIn)
            Button(action: performLogin) {
                Text("Login")
            }.disabled(email.isEmpty || logginIn)
        }
    }

    func performLogin() {
        logginIn = true
        Current.api.login(user: LoginUserRequest(
            email: email
        )).task { _ in
            self.onFinish()
            self.logginIn = false
        }
    }
}
