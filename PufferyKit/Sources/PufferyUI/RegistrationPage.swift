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
    
    @State var email: String = ""
    @State var inProgress = false
    @State var registrationError: FetchingError?
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: performRegister) {
                Text("GettingStarted.Registration.Anonymous")
            }.buttonStyle(RichButtonStyle())
                .show(when: !keyboard.isActive)
                .transition(.opacity)
                .disabled(inProgress)

            Spacer()
            
            HStack {
                VStack { Divider() }
                Text("OR")
                    .italic()
                    .font(.headline)
                VStack { Divider() }
            }.show(when: !keyboard.isActive).transition(.opacity)
            
            VStack {
                TextField("GettingStarted.Login.EmailPlaceholder", text: $email)
                    .multilineTextAlignment(.center)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(inProgress)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("Background").opacity(keyboard.isActive ? 0.75 : 0.25))
                    )

                Button(action: performLogin) {
                    Text("GettingStarted.Login.Perform")
                }.disabled(email.isEmpty || inProgress)
            }
            .padding()
            .padding(.bottom, keyboard.currentHeight)
            .animation(.default)
            
            Spacer()
        }.buttonStyle(RichButtonStyle())
    }
    
    func performLogin() {
        inProgress = true

        Current.api.login(user: LoginUserRequest(
            email: email
        )).task { _ in
            self.onFinish()
            self.inProgress = false
        }
    }
    
    func performRegister() {
        registrationError = nil
        inProgress = true

        PushNotifications.register {
            let createDeviceRequest = Current.store.state.session.latestDeviceToken.map {
                CreateDeviceRequest(token: $0)
            }
            Current.api.register(user: CreateUserRequest(device: createDeviceRequest)).task { result in
                switch result {
                case .success:
                    self.registrationError = nil
                    DispatchQueue.main.async {
                        self.onFinish()
                    }
                case let .failure(error):
                    self.inProgress = false
                    self.registrationError = error
                }
            }
        }
    }
}


#if DEBUG
    struct RegistrationPage_Previews: PreviewProvider {
        static var previews: some View {
            RegistrationPage(onFinish: {})
        }
    }
#endif
