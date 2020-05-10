//
//  RegistrationPage.swift
//
//
//  Created by Valentin Knabel on 03.05.20.
//

import SwiftUI

struct RegistrationPage: View {
    var onFinish: () -> Void

    @ObservedObject private var keyboard = Keyboard()
    @ObservedObject private var viewModel = RegistrationViewModel()

    var body: some View {
        VStack {
            Spacer()

            Button(action: { self.viewModel.shouldRegister(self.onFinish) }) {
                Text("GettingStarted.Registration.Anonymous")
            }.buttonStyle(RoundedButtonStyle())
                .show(when: !keyboard.isActive)
                .transition(.opacity)
                .disabled(viewModel.inProgress)

            Spacer()

            HStack {
                VStack { Divider() }
                Text("OR")
                    .italic()
                    .font(.headline)
                VStack { Divider() }
            }.show(when: !keyboard.isActive).transition(.opacity)

            VStack {
                TextField("GettingStarted.Login.EmailPlaceholder", text: $viewModel.email, onCommit: { self.viewModel.shouldRegister(self.onFinish) })
                    .textFieldStyle(RoundedTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(viewModel.inProgress)

                Button(action: { self.viewModel.shouldLogin(self.onFinish) }) {
                    Text("GettingStarted.Login.Perform")
                }
                .disabled(viewModel.email.isEmpty || viewModel.inProgress)
                .sheet(isPresented: self.$viewModel.shouldCheckEmails) {
                    EmailConfirmationPage(email: self.viewModel.email)
                }
            }
            .padding()
            .padding(.bottom, keyboard.currentHeight)
            .animation(.default)

            Spacer()
        }.buttonStyle(RoundedButtonStyle())
    }
}

#if DEBUG
    struct RegistrationPage_Previews: PreviewProvider {
        static var previews: some View {
            RegistrationPage(onFinish: {})
        }
    }
#endif
