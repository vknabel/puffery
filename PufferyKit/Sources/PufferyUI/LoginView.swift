//
//  LoginView.swift
//  Puffery
//
//  Created by Valentin Knabel on 27.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import SwiftUI

struct LoginView: View {
    var onFinish: () -> Void

    @State var email = ""
    @State var logginIn = false

    var body: some View {
        VStack {
            TextField("GettingStarted.Login.EmailPlaceholder", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disabled(logginIn)
            Button(action: performLogin) {
                Text("GettingStarted.Login.Perform")
            }.disabled(email.isEmpty || logginIn)
        }
    }

    func performLogin() {
//        logginIn = true
//        Current.api.login(user: LoginUserRequest(
//            email: email,
//            device:
//        )).task { _ in
//            self.onFinish()
//            self.logginIn = false
//        }
    }
}
